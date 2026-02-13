# **PHP Apache ModRewrite Docker Images**

This repository provides optimized Docker images based on the official php:apache image. It is specifically configured for web applications requiring URL rewriting and offers an extended variant for image-intensive applications.

The images are built automatically via GitHub Actions and published to the GitHub Container Registry (ghcr.io).

## **📦 Available Image Variants**

There are two main variants tailored to different use cases:

### **1\. Base Image (:latest, :8.x)**

**Registry Page:** [php-apache-mod2rewrite](https://github.com/reisi007/php-apache-mod2rewrite/pkgs/container/php-apache-mod2rewrite)

A lightweight version for standard web applications.

* **Base:** Official php:{version}-apache  
* **Modules:** mod\_rewrite enabled (for .htaccess support and clean URLs)  
* **Permissions:** www-data set as owner for /var/www/html

### **2\. Full Image (-imagick-exiftool)**

**Registry Page:** [php-apache-mod2rewrite-imagick-exiftool](https://github.com/reisi007/php-apache-mod2rewrite/pkgs/container/php-apache-mod2rewrite-imagick-exiftool)

A powerful version for applications with high image processing requirements (e.g., CMS, galleries, asset management).

* **Includes everything from the Base Image**  
* **System Tools:** exiftool, libmagickwand, various graphics libraries (jpeg, png, webp, avif, heif)  
* **PHP Extensions:**  
  * gd (configured with FreeType, JPEG, WebP, AVIF support)  
  * imagick  
  * exif  
  * zip  
* **Configuration:** Optimized for higher performance and larger uploads.

## **🏷️ Tags & Versions**

The images are built for the following PHP versions (defined in the build pipeline):

| PHP Version | Base Tag | Full Tag |
| :---- | :---- | :---- |
| **8.5 (Latest)** | latest, 8.5 | latest, 8.5 |
| **8.4** | 8.4 | 8.4 |
| **8.3** | 8.3 | 8.3 |
| **8.2** | 8.2 | 8.2 |

**Image Naming Convention:**

* Base: ghcr.io/reisi007/php-apache-mod2rewrite:\<tag\>  
* Full: ghcr.io/reisi007/php-apache-mod2rewrite-imagick-exiftool:\<tag\>

## **🚀 Usage**

### **Docker CLI**

Start the **Base Image**:

docker run \-d \-p 80:80 \-v $(pwd):/var/www/html ghcr.io/reisi007/php-apache-mod2rewrite:latest

Start the **Full Image**:

docker run \-d \-p 80:80 \-v $(pwd):/var/www/html ghcr.io/reisi007/php-apache-mod2rewrite-imagick-exiftool:latest

### **Docker Compose**

```yaml
services:  
  web:  
    image: ghcr.io/reisi007/php-apache-mod2rewrite-imagick-exiftool:8.3  
    ports:  
      \- "80:80"  
    volumes:  
      \- ./src:/var/www/html  
    restart: always
```

## **⚙️ Configuration Settings (Full Image)**

The "Full" image includes specific adjustments in php.ini and policy.xml for better performance during media processing:

**PHP Settings (uploads.ini):**

* memory\_limit: **1024M**  
* upload\_max\_filesize: **16M**  
* post\_max\_size: **16M**  
* max\_execution\_time: **600s**

**ImageMagick Policies (policy.xml):**

* Memory Limit increased to **4GiB**  
* Map Limit increased to **4GiB**  
* **Note:** Processing of AVIF and HEIC via ImageMagick Policy (coder) is explicitly disabled (rights="none") for compatibility reasons, even though the libraries are installed (imagick is not built with support for these formats).

## **🛠️ Build Process**

The build is performed automatically via GitHub Actions:

1. The workflow determines the PHP versions (Matrix).  
2. The version at index \[0\] of the list (currently 8.5) is automatically tagged as latest.  
3. The Base target and the Full target are built and pushed in parallel.
