//
//  ContentView.swift
//
//  Created by Pedrojimvi and JunZH0 on 15/2/23.
//

import SwiftUI

var isPeriodAllowed = true

struct ContentView: View {
    let grid = [
        ["C", "AC", "%", "/"],
        ["7", "8", "9", "x"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        [".", "0", "", "="]
    ]
    
    let operators = ["/", "+", "x", "%"]
    
    @State var visibleWorkings = ""
    @State var visibleResults = ""
    @State var showAlert = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(visibleWorkings)
                    .padding()
                    .foregroundColor(Color.white)
                    .font(.system(size: 30, weight: .heavy))
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack {
                Spacer()
                Text(visibleResults)
                    .padding()
                    .foregroundColor(Color.white)
                    .font(.system(size: 50, weight: .heavy))
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            
            ForEach(grid, id: \.self) {
                row in
                HStack {
                    ForEach(row, id: \.self) {
                        cell in
                        
                        Button(action: { buttonPressed(cell: cell)}, label: {
                            Text(cell)
                                .foregroundColor(buttonColor(cell))
                                .font(.system(size: 40, weight: .heavy))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                        })
                    }
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Operación no válida"),
                message: Text(visibleWorkings),
                dismissButton: .default(Text("Vale"))
            )
        }
    }
    
    func buttonColor(_ cell: String) -> Color {
        if(cell == "C" || cell == "AC") {
            return .red
        }
        
        if(cell == "-" || cell == "=" || operators.contains(cell)) {
            return .green
        }
        
        return .white
    }
    
    func buttonPressed(cell: String) {
        
        switch (cell) {
        case "C":
            visibleWorkings = ""
            visibleResults = ""
            isPeriodAllowed = true
        case "AC":
            visibleWorkings = String(visibleWorkings.dropLast())
            isPeriodAllowed = true
        case "=":
            visibleResults = calculateResults()
            isPeriodAllowed = true
        case "-":
            addMinus()
            isPeriodAllowed = true
        case "x", "/", "%", "+":
            addOperator(cell)
            isPeriodAllowed = true
        case ".":
            if  isPeriodAllowed == true {
                visibleWorkings += cell
                isPeriodAllowed = false
            }
        default:
            visibleWorkings += cell
        }
        
    }
    
    func addOperator(_ cell : String) {
        if !visibleWorkings.isEmpty {
            let last = String(visibleWorkings.last!)
            if operators.contains(last) {
                visibleWorkings.removeLast()
            }
            visibleWorkings += cell
        }
    }
    
    func addMinus() {
        if visibleWorkings.isEmpty || visibleWorkings.last! != "-" {
            visibleWorkings += "-"
        }
    }
    
    func calculateResults() -> String {
        if(validInput()) {
            var workings = visibleWorkings.replacingOccurrences(of: "%", with: "*0.01")
            workings = workings.replacingOccurrences(of: "x", with: "*")
            let expression = NSExpression(format: workings)
            let result = expression.expressionValue(with: nil, context: nil) as! Double
            return formatResult(val: result)
        }
        showAlert = true
        return ""
    }
    
    func validInput() -> Bool {
        if(visibleWorkings.isEmpty) {
            return false
        }
        let last = String(visibleWorkings.last!)
        
        if(operators.contains(last) || last == "-") {
            if(last != "%" || visibleWorkings.count == 1) {
                return false
            }
        }
        
        if visibleWorkings.contains("/"), let index = visibleWorkings.lastIndex(of: "/") {
            let denominator = String(visibleWorkings[visibleWorkings.index(after: index)...])
            if Double(denominator) == 0 {
                return false
            }
        }
        
        return true
    }
    
    func formatResult(val: Double) -> String {
        return String(format: "%g", val)
    }


}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
