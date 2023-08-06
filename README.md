<!-- Improved compatibility of back to top link: See: https://github.com/Bourne-Koloh/DVTApp/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/Bourne-Koloh/DVTApp">
    <img src="weatherapp/resources/logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Weather App</h3>

  <p align="center">
    An iOS utility weather app which uses open weather apis to show current weather and a forecast for 5 days ahead
    <br />
    <a href="https://openweathermap.org/"><strong>Explore the docs »</strong></a>
    <br />
    <br />
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project


This project is an iOS iPhone application and is build to offer users weather updates based on their current location

The project uses the below stacks:
* The target iOS is 12.4
* Supports both SwiftUI and UIKit Storyboards
* Uses MVC and MVVM architecture
* Supports dark mode

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

This is built on XCode 14 and Swift 5.2

* [![XCode][XCode]][xcode-url]
* [![Swift][swift]][swift-url]
* [![Open Weather][openweather]][open-weather-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

Your will need a apple developer environment for you to run this project

### Prerequisites

This is an example of how to list things you need to use the software and how to install them.
* Download and install latest XCode 
  ```sh
  https://apps.apple.com/us/app/xcode/id497799835?mt=12
  ```

### Installation


1. Signup and get a free API Key at [https://openweathermap.org/api](https://openweathermap.org/api)
2. You can clone this project directly from XCode or use your terminal as below
   ```sh
   git clone https://github.com/Bourne-Koloh/DVTApp.git
   ```
3. Double click `weatherapp.xcodeproj` to load the project in XCode
4. Enter your API in `Info.plist` 
   ```sh
   property = weather-api-key
   value = 'ENTER YOUR API'
   ```
5. Then build and the project in XCode or you cab build it from terminal by using the command below to build and launch on iPhone 14 emulator
    ```sh
    xcodebuild \
    -project weatherapp.xcodeproj \
    -scheme weatherapp \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.2' \
    test
    ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- ARCHITECTURE -->
## Architecture
The target iOS version is 12.4

This project is build on 2 architectures;

1. MVC (View ↔ Controller ↔ Model)
This architecture is the preferred pattern for UIKit build Views and Storyboards. The communication model adopted for this pattern in project is use of completion handlers to relay processing states and event between the Views and Models, managed by the controller


2. MVVM (View ↔ ViewModel ↔ Model)
This is the preferred pattern for SwiftUI Views, ViewModels and Models. The communication model is via View States, ObservedState on ViewModels and Combine Framework for managing Data Sources. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

By default the project will build on UIKit system, which is supported by all iOS versions.

To activate SwiftUI and MVVM pattern, in the project's `Info.plist` switch the `prefer-swiftui` to true and rebuild the project. If the test device is running iOS 13 and above the app will switch to using SwiftUI


<p align="right">(<a href="#readme-top">back to top</a>)</p>




<!-- ROADMAP -->
## Roadmap

- [x] Initial Project Commit
- [x] Add integration to Open Weather
- [x] Add Local Caching for forecast weather
- [ ] Multi-language Support
    - [ ] French
    - [ ] Spanish
- [ ] Release to apple store

The project has no open issues

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AwesomeFeature`)
3. Commit your Changes (`git commit -m 'Add some AwesomeFeature'`)
4. Push to the Branch (`git push origin feature/AwesomeFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Bourne Koloh - [@bourne_koloh](https://twitter.com/bourne_koloh) : bournekolo@icloud.com

Project Link: [https://github.com/Bourne-Koloh/WeatherApp](https://github.com/Bourne-Koloh/DVTApp)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

Resources from the below sites where useful


* [Open Weather](https://openweathermap.org/)
* [App Icon Generator](https://www.iconsgenerator.com/Home/AppIcons)
* [Best-README-Template](https://github.com/othneildrew/Best-README-Template)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->


[contributors-shield]: https://img.shields.io/github/contributors/Bourne-Koloh/DVTApp.svg?style=for-the-badge
[contributors-url]: https://github.com/Bourne-Koloh/DVTApp/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/Bourne-Koloh/DVTApp.svg?style=for-the-badge
[forks-url]: https://github.com/Bourne-Koloh/DVTApp/network/members
[stars-shield]: https://img.shields.io/github/stars/Bourne-Koloh/DVTApp.svg?style=for-the-badge
[stars-url]: https://github.com/Bourne-Koloh/DVTApp/stargazers
[issues-shield]: https://img.shields.io/github/issues/Bourne-Koloh/DVTApp.svg?style=for-the-badge
[issues-url]: https://github.com/Bourne-Koloh/DVTApp/issues
[license-shield]: https://img.shields.io/github/license/Bourne-Koloh/DVTApp.svg?style=for-the-badge
[license-url]: https://github.com/Bourne-Koloh/DVTApp/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew

[product-screenshot]: weatherapp/resources/screenshot.png
[XCode]: https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/58/25/3a/58253a1d-1cf2-c4a5-44a6-6bbc8ee6e274/Xcode-85-220-0-4-2x-sRGB.png/246x0w.webp
[xcode-url]: https://developer.apple.com/xcode/resources/
[Swift]: https://developer.apple.com/assets/elements/icons/swift-playgrounds/swift-playgrounds-96x96_2x.png
[swift-url]: https://developer.apple.com/swift-playgrounds/
[OpenWeather]: https://openweathermap.org/themes/openweathermap/assets/img/logo_white_cropped.png
[open-weather-url]: https://openweathermap.org/
