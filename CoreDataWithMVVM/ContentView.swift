//
//  ContentView.swift
//  CoreDataWithMVVM
//
//  Created by Weerawut Chaiyasomboon on 29/1/2567 BE.
//

import SwiftUI
import CoreData

class CoreDataViewModel: ObservableObject{
    @Published var savedEntities:[FruitEntity] = []
    
    let container: NSPersistentContainer
    
    init(){
        container = NSPersistentContainer(name: "FruitsContainer")
        container.loadPersistentStores { description, error in
            if let error = error{
                print("ERROR LOADING CORE DATA: \(error)")
            }else{
                print("SUCCESSFULLY LOADING CORE DATA.")
            }
        }
        fetchFruits()
    }
    
    func fetchFruits(){
        let request = NSFetchRequest<FruitEntity>(entityName: "FruitEntity")
        
        do{
            savedEntities = try container.viewContext.fetch(request)
        }catch let error{
            print("ERROR FETCHING: \(error)")
        }
    }
    
    func addFruit(text: String){
        let newFruit = FruitEntity(context: container.viewContext)
        newFruit.name = text
        saveData()
    }
    
    func updateFruit(entity: FruitEntity){
        let currentName = entity.name ?? ""
        let newName = currentName + "!"
        entity.name = newName
        saveData()
    }
    
    func deleteFruit(indexSet: IndexSet){
        guard let index = indexSet.first else { return }
        let entity = savedEntities[index]
        container.viewContext.delete(entity)
        saveData()
    }
    
    func saveData(){
        do{
            try container.viewContext.save()
            fetchFruits()
        }catch let error{
            print("ERROR SAVING: \(error)")
        }
    }
}

struct ContentView: View {
    @StateObject var vm = CoreDataViewModel()
    @State private var textFieldText = ""
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 20){
                TextField("Add fruit here ...", text: $textFieldText)
                    .font(.headline)
                    .padding(.leading)
                    .frame(height: 55)
                    .background(.gray.opacity(0.25))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button(action: {
                    guard !textFieldText.isEmpty else { return }
                    vm.addFruit(text: textFieldText)
                    textFieldText = ""
                }, label: {
                    Text("Add")
                        .font(.headline)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .background(.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                })
                
                List{
                    ForEach(vm.savedEntities) { entity in
                        Text(entity.name ?? "NO NAME")
                            .onTapGesture {
                                vm.updateFruit(entity: entity)
                            }
                    }
                    .onDelete(perform: vm.deleteFruit(indexSet:))
                }
                .listStyle(.plain)
                
                Spacer()
            }
            .navigationTitle("Fruits")
        }
    }
}

#Preview {
    ContentView()
}
