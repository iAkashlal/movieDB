//
//  MovieModel.swift
//  TMDb-Framework
//
//  Created by Akashlal on 14/03/20.
//  Copyright © 2020 AkOS. All rights reserved.
//

import Foundation

public class MovieModel : NSObject, Codable {

    public let page : Int?
    public let results : [MovieData]?
    public let totalPages : Int?
    public let totalResults : Int?


}

public class MovieData : NSObject, Codable {

    public let adult : Bool?
    public let backdropPath : String?
    public let genreIds : [Int]?
    public let id : Int?
    public let originalLanguage : String?
    public let originalTitle : String?
    public let overview : String?
    public let popularity : Float?
    public let posterPath : String?
    public let releaseDate : String?
    public let title : String?
    public let video : Bool?
    public let voteAverage : Float?
    public let voteCount : Int?
    public var posterLink: String{
        "https://image.tmdb.org/t/p/w500\(posterPath!)"
    }

}
