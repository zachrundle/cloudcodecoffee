-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<br />

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

CloudCodeCoffee is going to be a blogging page that I hosted within AWS. The following AWS services will be used:
- S3 (static site feature)
- CloudFront to sit in front to provide static content caching, an extra layer of security, and most importantly HTTPS access to the S3 bucket
- ACM to issue SSL certificate to support HTTPS
- Route53 to create appropriate DNS records 


<!-- ROADMAP -->
## Roadmap

- [ ] Build infrastructure for blog (S3, CloudFront, ACM, Route53) using Terraform
- [ ] Utilize existing templates for HTML, CSS, and JS code for blog hosted on S3 static site
- [ ] Start publishing blogs!
    - [ ] AWS 
    - [ ] cloud architecture
    - [ ] IT certifications



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/zachrundle/cloudcodecoffee.svg?style=for-the-badge
[contributors-url]: https://github.com/zachrundle/cloudcodecoffee/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/zachrundle/cloudcodecoffee.svg?style=for-the-badge
[forks-url]: https://github.com/zachrundle/cloudcodecoffee/network/members
[stars-shield]: https://img.shields.io/github/stars/zachrundle/cloudcodecoffee.svg?style=for-the-badge
[stars-url]: https://github.com/zachrundle/cloudcodecoffee/stargazers
[issues-shield]: https://img.shields.io/github/issues/zachrundle/cloudcodecoffee.svg?style=for-the-badge
[issues-url]: https://github.com/zachrundle/cloudcodecoffee/issues
[license-shield]: https://img.shields.io/github/license/zachrundle/cloudcodecoffee.svg?style=for-the-badge
[license-url]: https://github.com/zachrundle/cloudcodecoffee/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/zach-rundle
[product-screenshot]: images/screenshot.png

