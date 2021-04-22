//
//  ContentView.swift
//  BucketList
//
//  Created by admin on 21.04.2021.
//

import SwiftUI
import MapKit
import LocalAuthentication

struct ContentView: View {
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var locations = [CodableMKPointAnnotation]()
    @State private var selectedPlace: MKPointAnnotation?
    @State private var showingPlaceDetails = false
    @State private var showingEditScreen = false
    @State private var isUnlocked = false
    
    var body: some View {
        ZStack {
            if !isUnlocked{
                
            MapView(centerCoordinate: $centerCoordinate, selectedPlace: $selectedPlace, showingPlaceDetails: $showingPlaceDetails, annotations: locations)
                .edgesIgnoringSafeArea(.all)
            Circle()
                .fill(Color.blue)
                .opacity(0.3)
                .frame(width: 32, height: 32, alignment: .center)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    PlusButton(locations: $locations, selectedPlace: $selectedPlace,
                               centerCoordinate: $centerCoordinate, showingEditScreen: $showingEditScreen)
                }
            }
            } else {
                Button("Unlock Places") {
                    self.authenticate()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .alert(isPresented: $showingPlaceDetails, content: {
            Alert(title: Text(selectedPlace?.title ?? "Unknown"),
                  message: Text(selectedPlace?.subtitle ?? "Missing place infomation"),
                  primaryButton: .default(Text("Ok")),
                  secondaryButton: .default(Text("Edit")){
                    self.showingEditScreen = true
                  })
        })
        .sheet(isPresented: $showingEditScreen, onDismiss: saveData, content: {
            if self.selectedPlace != nil {
                EditView(placemark: self.selectedPlace!)
            }
        })
        .onAppear() {
            loadData()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadData() {
        let fileName = getDocumentsDirectory().appendingPathComponent("SavedPlace")
        
        do {
            let data = try Data(contentsOf: fileName)
            locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
        } catch {
            print("Unable to load saved data \(error.localizedDescription)")
        }
    }
    
    func saveData() {
        do {
            let fileName = getDocumentsDirectory().appendingPathComponent("SavedPlace")
            let data = try JSONEncoder().encode(self.locations)
            try data.write(to: fileName, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("unable to save data")
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "we need unlock uoyu"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        // error
                    }
                }
            }
        } else {
            // no biometrics
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




struct PlusButton: View {
    @Binding var locations: [CodableMKPointAnnotation]
    @Binding var selectedPlace: MKPointAnnotation?
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var showingEditScreen: Bool
    
    var body: some View {
        Button(action: {
            let newLocation = CodableMKPointAnnotation()
            newLocation.title = "Example location"
            newLocation.coordinate = self.centerCoordinate
            self.locations.append(newLocation)
            self.selectedPlace = newLocation
            self.showingEditScreen = true
            
        }, label: {
            Image(systemName: "plus")
        })
        .padding()
        .background(Color.black.opacity(0.75))
        .foregroundColor(.white)
        .font(.title)
        .clipShape(Circle())
        .padding(.trailing)
    }
}
