# **PHP Apache ModRewrite Docker Images**

This repository provides optimized Docker images based on the official php:apache image. It is specifically configured for web applications requiring URL rewriting and offers extended variants for image-intensive applications and MariaDB/MySQL database connections.

The images are built automatically via GitHub Actions and published to the GitHub Container Registry (ghcr.io).

## **📦 Available Image Variants**

There are four main variants tailored to different use cases:

### **1\. Base Image (:latest, :8.x)**
A lightweight version for standard web applications.

* **Base:** Official php:{version}-apache  
* **Modules:** mod\_rewrite enabled (for .htaccess support and clean URLs)  
* **Permissions:** www-data set as owner for /var/www/html

### **2\. Base Image with MariaDB PDO (-maria-pdo)**
Includes everything from the Base Image, plus the `pdo_mysql` PHP extension for connecting to MariaDB/MySQL databases.

### **3\. Full Image (-imagick-exiftool)**
A powerful version for applications with high image processing requirements (e.g., CMS, galleries, asset management).

* **Includes everything from the Base Image** * **System Tools:** exiftool, libmagickwand, various graphics libraries (jpeg, png, webp, avif, heif)  
* **PHP Extensions:** * gd (configured with FreeType, JPEG, WebP, AVIF support)  
  * imagick  
  * exif  
  * zip  
* **Configuration:** Optimized for higher performance and larger uploads.

### **4\. Full Image with MariaDB PDO (-imagick-exiftool-maria-pdo)**
Includes everything from the Full Image, plus the `pdo_mysql` PHP extension.

## **🏷️ Tags & Versions**

The images are built for the following PHP versions (defined in the build pipeline):

| PHP Version | Base Tag | Base + MariaDB PDO Tag | Full Tag | Full + MariaDB PDO Tag |
| :---- | :---- | :---- | :---- | :---- |
| **8.5 (Latest)** | latest, 8.5 | -maria-pdo:latest, -maria-pdo:8.5 | -imagick-exiftool:latest, -imagick-exiftool:8.5 | -imagick-exiftool-maria-pdo:latest, -imagick-exiftool-maria-pdo:8.5 |
| **8.4** | 8.4 | -maria-pdo:8.4 | -imagick-exiftool:8.4 | -imagick-exiftool-maria-pdo:8.4 |
| **8.3** | 8.3 | -maria-pdo:8.3 | -imagick-exiftool:8.3 | -imagick-exiftool-maria-pdo:8.3 |
| **8.2** | 8.2 | -maria-pdo:8.2 | -imagick-exiftool:8.2 | -imagick-exiftool-maria-pdo:8.2 |

**Image Naming Convention Examples:**

* Base: `ghcr.io/reisi007/php-apache-mod2rewrite:<tag>`  
* Base + MariaDB PDO: `ghcr.io/reisi007/php-apache-mod2rewrite-maria-pdo:<tag>`
* Full: `ghcr.io/reisi007/php-apache-mod2rewrite-imagick-exiftool:<tag>`
* Full + MariaDB PDO: `ghcr.io/reisi007/php-apache-mod2rewrite-imagick-exiftool-maria-pdo:<tag>`

## **🚀 Usage**

### **Docker CLI**

Start the **Base Image with MariaDB PDO**:

```bash
docker run -d -p 80:80 -v $(pwd):/var/www/html ghcr.io/reisi007/php-apache-mod2rewrite-maria-pdo:latest