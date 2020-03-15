//
//  ViewController.swift
//  TMDb-Client
//
//  Created by Akashlal on 13/03/20.
//  Copyright © 2020 AkOS. All rights reserved.
//

import UIKit
import TMDb_Framework
import SDWebImage


class HomeVC: UIViewController {
    
    var searchQuery = ""
    var selectedIndex: Int = 1
    var searchResults: [MovieBinding] = []
    var context : Context = .discover
    var manager: TMDbManager!
    
    //Search Results Empty view
    @IBOutlet weak var searchResultsEmptyView: UIView!
    @IBOutlet weak var searchQueryLabel: UILabel!
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchQueryTextField: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Lifecycle Management
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Using the custom built TMDbFramework and its delegate methods in the extension
        manager = TMDbManager.shared()
        manager.delegate = self //Set delegate to ensure successful callbacks
        
        self.performNamedSearch(forName: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    //MARK: - Custom methods
    func refresh(){
        DispatchQueue.main.async {
            self.searchResultsEmptyView.alpha = 0
            self.collectionView.reloadData()
        }
    }
    func performNamedSearch(forName name: String){
        self.searchResults.removeAll()
        refresh()
        if name == ""{
            self.context = .discover
            manager.getInitialMovies(isInitial: true)
        }
        else{
            self.context = .search
            manager.getMoviesFor(name: name, isInitial: true)
        }
    }
    private func nextResults() {
        if self.context == .discover{
            manager.getInitialMovies()
        }
        else {
            manager.getMoviesFor(name: self.searchQuery)
        }
    }
    private func showDetail() {
        performSegue(withIdentifier: "showDetailsSegue", sender: self)
    }
    
    //MARK: - IBActions
    @IBAction func searchButtonPressed(_ sender: Any) {
        self.searchView.isHidden = false
    }
    
    @IBAction func searchAction(_ sender: Any) {
        self.searchQuery = self.searchQueryTextField.text ?? ""
        DispatchQueue.main.async {
            self.searchQueryTextField.text = ""
            self.searchView.isHidden = true
            self.searchQueryTextField.resignFirstResponder()
        }
        self.performNamedSearch(forName: self.searchQuery)
    }
    @IBAction func cancelSearchAction(_ sender: Any) {
        DispatchQueue.main.async{
            self.searchView.isHidden = true
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsSegue"{
            if let detailsVC = segue.destination as? MovieDetailsVC{
                detailsVC.movie = self.searchResults[self.selectedIndex]
            }
        }
    }
}

//MARK: - UICollectionView functions
extension HomeVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath)
        if let cell = cell as? CollectionViewCell{
            cell.movieTitle.text = searchResults[indexPath.row].title
            //cell.movieImage = searchResults[indexPath.row].thumbnail
            cell.movieImage.sd_setImage(with: URL(string: searchResults[indexPath.row].thumbnail))
        }
        return cell
    }
    
}

extension HomeVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.showDetail()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.searchResults.count-1{
            self.nextResults()
        }
    }
}

extension HomeVC: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.frame.maxX/2)-CGFloat(10)
        return CGSize(width: width, height: width*1.5)
    }
}

//MARK: - TMDbManager Framework Delegates
extension HomeVC: TMDbManagerDelegate{
    func discoverNewMoviesSuccessWith(movies: [MovieData]) {
        //Show these movies on homepage when user first opens the application
        DispatchQueue.main.async {
            self.title = "What's Trending!"
        }
        movies.forEach {
            guard let title = $0.title, let originalTitle = $0.originalTitle, let thumbnail = $0.posterLink, let synopsis = $0.overview, let rating = $0.voteAverage else {
                self.presentAlert(title: "Error", description: "We can't seem to find a poster for a movie you might like! Apologies.")
                return
            }
            let movieData = MovieBinding(title: title, originalTitle: originalTitle, thumbnail: thumbnail, synopsis: synopsis, rating: rating, released: $0.releasedOn ?? "Unknown")
            self.searchResults.append(movieData)
        }
        refresh()
    }
    func discoverNewMoviesFailedWith(error: String) {
        //Handle what happens when homepage cant load any movies.
        self.presentAlert(title: "Error!", description: error)
    }
    
    func getMoviesForNamedSearchSuccessWith(movies: [MovieData]) {
        //ToDo: Hangle what happens when movie search call is successful
        DispatchQueue.main.async {
            self.title = "Results for \(self.searchQuery)"
        }
        movies.forEach {
            guard let title = $0.title, let originalTitle = $0.originalTitle, let thumbnail = $0.posterLink, let synopsis = $0.overview, let rating = $0.voteAverage else {
                self.presentAlert(title: "Error", description: "We can't seem to find a poster for a movie you might like! Apologies.")
                return
            }
            let movieData = MovieBinding(title: title, originalTitle: originalTitle, thumbnail: thumbnail, synopsis: synopsis, rating: rating, released: $0.releasedOn ?? "Unknown")
            self.searchResults.append(movieData)
        }
        refresh()
    }
    func getMoviesForNamedSearchFailedWith(error: String) {
        //Handle what happens when named movie call fails
        self.presentAlert(title: "Error!", description: error)
    }
    func searchResultsEmpty() {
        //Handle what happens when search results are empty. PS. Show a view asking user to search for something else.
        DispatchQueue.main.async{
            self.searchQueryLabel.text = "\""+self.searchQuery+"\""
            self.searchResultsEmptyView.alpha = 1
            self.title = "No Movies Found :("
        }
        
    }
}
