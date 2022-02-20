//
//  ViewController.swift
//  News App
//
//  Created by Иван Зайцев on 05.02.2022.
//

import UIKit
import Network
class ViewController: UIViewController {
    let defaults = UserDefaults.standard
    var url = "https://newsapi.org/v2/everything?q=world&language=ru&sortBy=publishedAt&apiKey=690c31ab91db44709b2940337102598f"
    var articles = [Article]()
    let myRefreshControll: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    var pickerView = UIPickerView()
    let subjectArray = ["Beauty","Science","Covid","Politics","Games","Cinema","IT","Hobby","Travelling","Entertainment", "Fun","World", "Business","Investments"]
    let subjectArrayLowerCase = ["beauty","science","covid","politics","games","cinema","it","hobby","travelling", "entertainment", "fun", "world", "business", "investments"]
    var language = "ru"
    let languageArray = ["ru", "en"]
    var subject = "world"
    let monitor = NWPathMonitor()
    
    
    @IBOutlet weak var languageChangeOutlet: UISegmentedControl!
    
    @IBOutlet weak var textViewSubject: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func languageChangeControl(_ sender: UISegmentedControl) {
//        let languageArray = ["ru", "en"]
        language = languageArray[sender.selectedSegmentIndex]
        defaults.set(language, forKey: "language")
        url = "https://newsapi.org/v2/everything?q=\(subject)&language=\(language)&sortBy=publishedAt&apiKey=690c31ab91db44709b2940337102598f"
        downloadJson(url: url)
        tableView.reloadData()
    }
    func checkLanguageMatch() {
//        print(defaults.object(forKey: "language"))
        language = defaults.object(forKey: "language")  as? String ?? "ru"
        let index = languageArray.firstIndex(of: defaults.object(forKey: "language")  as? String ?? "ru")!
//        print(index)
        languageChangeOutlet.selectedSegmentIndex = index
    }
    
    
    
    override func viewDidLoad() {
         //For light mode
        checkLanguageMatch()
        pickerView.delegate = self
        pickerView.dataSource = self
        textViewSubject.inputView = pickerView
        tableView.refreshControl = myRefreshControll
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        monitorNetwork()
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        if defaults.array(forKey: "Titles") == nil {
            downloadJson(url: url)
        }
        tableView.reloadData()
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        url = "https://newsapi.org/v2/everything?q=\(subject)&language=\(language)&sortBy=publishedAt&apiKey=690c31ab91db44709b2940337102598f"
        downloadJson(url: url)
        tableView.reloadData()
        sender.endRefreshing()
    }

    
    func downloadJson(url: String) {
        guard let downloadURL = URL(string: url) else { return }
        URLSession.shared.dataTask(with: downloadURL) { data, urlResponse, error in
            guard let data = data, error == nil, urlResponse != nil else {
//                print("something is wrong")
                return
            }
//            print("downloaded")
            do
            {
                let decoder = JSONDecoder()
                let downloadedNews = try decoder.decode(News.self, from: data)
                self.articles = downloadedNews.articles
                self.resetDefaults()
                self.putInDefaults(articles: downloadedNews.articles)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    
    func putInDefaults(articles: [Article]) {
        var userDefaultsTitles: [String] = []
        var userDefaultsDescriptions: [String] = []
        var userDefaultsUrls: [String] = []
        for i in 0..<articles.count {
            if articles[i].description != "null" {
                userDefaultsDescriptions.append(articles[i].description)
            } else {
                userDefaultsDescriptions.append("No data :/")
            }
            if articles[i].title != "null" {
                userDefaultsTitles.append(articles[i].title)
            } else {
                userDefaultsDescriptions.append("No data :/")
            }
            if articles[i].url != "null" {
                userDefaultsUrls.append(articles[i].url)
            } else {
                userDefaultsDescriptions.append("No data :/")
            }
            defaults.set(0, forKey: "Visits\(i)")
        }
        resetDefaults()
        defaults.set(userDefaultsUrls, forKey: "Urls")
        defaults.set(userDefaultsDescriptions, forKey: "Descriptions")
        defaults.set(userDefaultsTitles, forKey: "Titles")
        
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        defaults.set(language, forKey: "language")
    }
    func monitorNetwork() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.sync {
//                    print("white")
                    self.view.backgroundColor = .white
                }
            } else {
                DispatchQueue.main.async {
//                    print("red")
                    self.view.backgroundColor = .red
                }
            }
        }
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
}
//MARK: - UITableViewDataSource
    

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if defaults.array(forKey: "Titles") != nil {
            return defaults.array(forKey: "Titles")!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as? TitleCell else { return UITableViewCell() }
        if defaults.array(forKey: "Titles") != nil {
            cell.titleText.text =  "\(defaults.array(forKey: "Titles")![indexPath.row])"
            cell.countLable.text = "\(defaults.integer(forKey: "Visits\(indexPath.row)"))"
        } else {
            cell.titleText.text =  ""
            cell.countLable.text = ""
        }
        return cell
    }
}

//MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if defaults.array(forKey: "Titles") != nil {
            defaults.set(defaults.integer(forKey: "Visits\(indexPath.row)") + 1, forKey: "Visits\(indexPath.row)")
            defaults.set(indexPath.row, forKey: "PickedNew")
        }
        self.performSegue(withIdentifier: "goToRead", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToRead" {
            let destinationVC = segue.destination as! ReadingViewController
            destinationVC.pickedPosition  = defaults.integer(forKey: "PickedNew")
        }
    }
}
//MARK: - UIPicker
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return subjectArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return subjectArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textViewSubject.text = subjectArray[row]
        textViewSubject.resignFirstResponder()
//        print(subjectArray[row])
        subject = subjectArrayLowerCase[row]
        url = "https://newsapi.org/v2/everything?q=\(subject)&language=\(language)&sortBy=publishedAt&apiKey=690c31ab91db44709b2940337102598f"
        downloadJson(url: url )
        tableView.reloadData()
    }
}
