# SwiftUIPageView

SwiftUIPageView is an alternative for SwiftUI's TabView using a PageTabViewStyle. This library exists because TabView was misbehaving when located in a ScrollView with content located below it.

## Author

Axel Ancona Esselmann, axel@anconaesselmann.com

## License

SwiftUIPageView is available under the MIT license. See the LICENSE file for more info.


```swift
struct ContentView: View {

    @State
    var selected: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                PageView(selected: $selected) { index in
                    switch index {
                    case 0:
                        ExampleContent(
                            text: "Page A",
                            count: 30,
                            color: .red.opacity(0.3)
                        ).id(0)
                    case 1:
                        ExampleContent(
                            text: "Page B",
                            count: 5,
                            color: .orange.opacity(0.3)
                        ).id(1)
                    case 2:
                        ExampleContent(
                            text: "Page C",
                            count: 21,
                            color: .yellow.opacity(0.3)
                        ).id(2)
                    case 3:
                        Text("Hello world")
                            .padding(32)
                    default: EmptyView()
                    }
                }
                Text("Content below PageView")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(32)
                    .background(.blue)
            }
        }
    }
}

struct ExampleContent: View {

    let text: String
    let count: Int
    let color: Color

    var body: some View {
        VStack {
            ForEach(0..<count, id: \.self) { index in
                Text("\(text) \(index)")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(color)
    }
}
```

![Nov-19-2024 13-26-10](https://github.com/user-attachments/assets/115909e3-e6f6-4973-838f-ee7153f53d1c)
