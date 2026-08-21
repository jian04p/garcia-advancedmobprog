# garcia_advmobprog

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Lab Activity 2: Discussion

The product model converts the JSON records returned by the API into typed
Flutter objects. `ProductService` owns the HTTP request and returns those
models to the screens, keeping API code out of the UI. The product screen uses
that service to render a searchable product grid, while the details screen
receives the selected model and displays its complete information.

This activity applies a layered design pattern: models represent data,
services retrieve it, providers hold shared app state, and screens/widgets
render and interact with the user interface. Separating these responsibilities
makes the app easier to test, maintain, and extend.
