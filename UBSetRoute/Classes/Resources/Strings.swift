//
//  Strings.swift
//  UBSetRoute
//
//  Created by Usemobile on 27/03/19.
//

import Foundation

extension String {
    
    static var origin: String {
        switch currentLanguage {
        case .en:
            return "Origin"
        case .pt:
            return "Origem"
        case .es:
            return "Origen"
        }
    }
    
    static var whereTo: String {
        switch currentLanguage {
        case .en:
            return "Where to?"
        case .pt:
            return "Para onde?"
        case .es:
            return "Para donde?"
        }
    }
    
    static var ready: String {
        switch currentLanguage {
        case .en:
            return "DONE"
        case .pt:
            return "PRONTO"
        case .es:
            return "LISTO"
        }
    }
    
    static var loading: String {
        switch currentLanguage {
        case .en:
            return "Loading..."
        case .pt:
            return "Carregando..."
        case .es:
            return "Cargando..."
        }
    }
    
    static var currentLocation: String {
        switch currentLanguage {
        case .en:
            return "Current location"
        case .pt:
            return "Localização atual"
        case .es:
            return "Lozalización actual"
        }
    }
    
    static var selectAtMap: String {
        switch currentLanguage {
        case .en:
            return "Set a place at map"
        case .pt:
            return "Escolha um local no mapa"
        case .es:
            return "Elige una ubicación en el mapa"
        }
    }
    
    static var useCurrentLocation: String {
        switch currentLanguage {
        case .en:
            return "Use current location"
        case .pt:
            return "Usar localização atual"
        case .es:
            return "Usar ubicación actual"
        }
    }
    
    static var lastPlaces: String {
        switch currentLanguage {
        case .en:
            return "RECENT PLACES"
        case .pt:
            return "ÚLTIMOS LOCAIS"
        case .es:
            return "ÚLTIMOS LOCAIS"
        }
    }
    
    static var resquestTravel: String{
        switch currentLanguage {
        case .en:
            return "Request"
        case .pt:
            return "Solicitação"
        case .es:
            return "Solicitud"
        }
    }
    
//    static var model: String {
//        switch currentLanguage {
//        case .en:
//            return ""
//        case .pt:
//            return ""
//        }
//    }
    
}

