# Introduction

Sample project for replicating segmentation fault error in allauth saml integration. https://mocksaml.com/
is configured as Identity provider for testing.

We have added below code in `manage.py` to output logs for segfault.

The error is occurring in Mac only. In Ubuntu 20.04 (docker setup instruction below) it is working correctly.

```python
import faulthandler
faulthandler.enable()
```

## Setup
Python version for below setup is `3.10.12`
```shell
python -V                                                                                                                        ─╯
Python 3.10.12

```

```shell
git clone https://github.com/vinodpandey/saml-allauth-demo.git
cd saml-allauth-demo

python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

```

## Testing
- Run django server. sqlite database is already included in the repository. There is no need to run
migrations
```shell
python manage.py runserver
```  
- access `http://localhost:8000` and click on `SSO Login`. This will redirect to https://mocksaml.com/ IdP 
authentication page. Click on `Sign In` and it will redirect back our home page.
- Click on `Logout` button.
- Repeat above 2 steps for approx 10 times. The segfault occurs for me after 4-5 tries.


## Setup with Docker
Build container and start the server
```shell
docker-compose build
docker-compose up
```
Rebuilding container after any code change
```shell
docker-compose build
docker-compose up
```

## checking which libxml version xmlsec1 is using
```
dpkg -L libxmlsec1 | grep libxmlsec1.so
/usr/lib/aarch64-linux-gnu/libxmlsec1.so.1.2.28
/usr/lib/aarch64-linux-gnu/libxmlsec1.so.1

ldd /usr/lib/aarch64-linux-gnu/libxmlsec1.so.1 | grep libxml2
libxml2.so.2 => /lib/aarch64-linux-gnu/libxml2.so.2 (0x0000ffff9c417000)

dpkg -L libxml2 | grep libxml2.so
/usr/lib/aarch64-linux-gnu/libxml2.so.2.9.10
/usr/lib/aarch64-linux-gnu/libxml2.so.2


```
## xmlsec and lxml in Ubuntu 20.04
```
xmlsec1-config --version
1.2.28

apt-cache show libxmlsec1

Package: libxmlsec1
Status: install ok installed
Priority: optional
Section: libs
Installed-Size: 431
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Architecture: arm64
Multi-Arch: same
Source: xmlsec1
Version: 1.2.28-2
Depends: libc6 (>= 2.17), libxml2 (>= 2.7.4), libxslt1.1 (>= 1.1.25)
Breaks: libreoffice-core (<< 1:6.0.5~rc2~)
Description: XML security library
 The XML Security Library implements standards related to secure handling
 of XML data.
 .
 This package provides dynamic libraries for use by applications.
 Specifically, it provides all XML security library functionality
 except for the cryptography engine.
Description-md5: 62646b37b26c7e3af663dfd0df5fdba3
Original-Maintainer: Debian XML/SGML Group <debian-xml-sgml-pkgs@lists.alioth.debian.org>
Homepage: https://www.aleksey.com/xmlsec/




pkg-config --modversion libxml-2.0
2.9.10

dpkg -l | grep libxml2-dev
ii  libxml2-dev:arm64           2.9.10+dfsg-5ubuntu0.20.04.6      arm64        Development files for the GNOME XML library

apt-cache show libxml2

Package: libxml2
Status: install ok installed
Priority: optional
Section: libs
Installed-Size: 1851
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Architecture: arm64
Multi-Arch: same
Version: 2.9.10+dfsg-5ubuntu0.20.04.6
Depends: libc6 (>= 2.29), libicu66 (>= 66.1-1~), liblzma5 (>= 5.1.1alpha+20120614), zlib1g (>= 1:1.2.3.3)
Description: GNOME XML library
 XML is a metalanguage to let you design your own markup language.
 A regular markup language defines a way to describe information in
 a certain class of documents (eg HTML). XML lets you define your
 own customized markup languages for many classes of document. It
 can do this because it's written in SGML, the international standard
 metalanguage for markup languages.
 .
 This package provides a library providing an extensive API to handle
 such XML data files.
Description-md5: 6771e66f557fa0f71e6955303e1d8f8d
Homepage: http://xmlsoft.org
Original-Maintainer: Debian XML/SGML Group <debian-xml-sgml-pkgs@lists.alioth.debian.org>

```

lxml
```
pip3.10 show lxml
Name: lxml
Version: 4.9.3
Summary: Powerful and Pythonic XML processing library combining libxml2/libxslt with the ElementTree API.
Home-page: https://lxml.de/
Author: lxml dev team
Author-email: lxml-dev@lxml.de
License: BSD-3-Clause
Location: /usr/local/lib/python3.10/site-packages
Requires:
Required-by: python3-saml, xmlsec

python3.10 -c "import lxml.etree as etree;print(etree.LXML_VERSION);print(etree.LIBXML_VERSION);print(etree.LIBXML_COMPILED_VERSION);"
(4, 9, 3, 0)
(2, 10, 3)
(2, 10, 3)

LIBXML_VERSION and LIBXML_COMPILED_VERSION are same. As per ChatGPT, it might mean that lxml 
is using its bundled version of libxml2.

```

xmlsec
```
pip3.10 show xmlsec
Name: xmlsec
Version: 1.3.13
Summary: Python bindings for the XML Security Library
Home-page: https://github.com/mehcode/python-xmlsec
Author: Bulat Gaifullin
Author-email: support@mehcode.com
License: MIT
Location: /usr/local/lib/python3.10/site-packages
Requires: lxml
Required-by: python3-saml


ldd $(python3.10 -c "import xmlsec; print(xmlsec.__file__)")
linux-vdso.so.1 (0x0000ffffa64d4000)
libxmlsec1-openssl.so.1 => /lib/aarch64-linux-gnu/libxmlsec1-openssl.so.1 (0x0000ffffa6421000)
libxmlsec1.so.1 => /lib/aarch64-linux-gnu/libxmlsec1.so.1 (0x0000ffffa63ab000)
libxml2.so.2 => /lib/aarch64-linux-gnu/libxml2.so.2 (0x0000ffffa61f5000)
libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6 (0x0000ffffa6082000)
/lib/ld-linux-aarch64.so.1 (0x0000ffffa64a4000)
libcrypto.so.1.1 => /lib/aarch64-linux-gnu/libcrypto.so.1.1 (0x0000ffffa5df3000)
libxslt.so.1 => /lib/aarch64-linux-gnu/libxslt.so.1 (0x0000ffffa5da5000)
libdl.so.2 => /lib/aarch64-linux-gnu/libdl.so.2 (0x0000ffffa5d91000)
libicuuc.so.66 => /lib/aarch64-linux-gnu/libicuuc.so.66 (0x0000ffffa5ba4000)
libz.so.1 => /lib/aarch64-linux-gnu/libz.so.1 (0x0000ffffa5b7a000)
liblzma.so.5 => /lib/aarch64-linux-gnu/liblzma.so.5 (0x0000ffffa5b46000)
libm.so.6 => /lib/aarch64-linux-gnu/libm.so.6 (0x0000ffffa5a9b000)
libpthread.so.0 => /lib/aarch64-linux-gnu/libpthread.so.0 (0x0000ffffa5a6a000)
libicudata.so.66 => /lib/aarch64-linux-gnu/libicudata.so.66 (0x0000ffffa3f9b000)
libstdc++.so.6 => /lib/aarch64-linux-gnu/libstdc++.so.6 (0x0000ffffa3db6000)
libgcc_s.so.1 => /lib/aarch64-linux-gnu/libgcc_s.so.1 (0x0000ffffa3d92000)

```

