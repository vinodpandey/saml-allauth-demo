# Introduction

Sample project for replicating segmentation fault error in allauth saml integration. https://mocksaml.com/
is configured as Identity provider for testing.

We have added below code in `manage.py` to output logs for segfault.

```python
import faulthandler
faulthandler.enable()
```

The error is occurring in Mac only. In Ubuntu 20.04 (docker setup instruction below) it is working correctly.

This issue was discussed at https://github.com/pennersr/django-allauth/issues/3593 and more details are at https://github.com/pennersr/django-allauth/issues/3593#issuecomment-1913433254

In Mac M2, after `pip install lxml==5.1.0` the issue got fixed. The details are in above link.

## Setup
Python version for below setup is `3.10.12`
```shell
python -V
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

## In Mac
```

python -c "import lxml.etree as etree;print(etree.LXML_VERSION);print(etree.LIBXML_VERSION);print(etree.LIBXML_COMPILED_VERSION);"
(4, 9, 3, 0)
(2, 9, 13)
(2, 9, 13)

Here LIBXML_VERSION (2, 9, 13) is Mac system installed libxml2 version. It is not using our
brew installed libxml2

Mac libxml version:
/usr/bin/xmllint --version                                                                                                             ─╯
/usr/bin/xmllint: using libxml version 20913
libxml - 2.9.13

brew info libxml2
libxml2: stable 2.12.4 (bottled), HEAD [keg-only]

brew ls libxml2                                                                                                                        ─╯
/usr/local/Cellar/libxml2/2.12.4/bin/xml2-config
/usr/local/Cellar/libxml2/2.12.4/bin/xmlcatalog
/usr/local/Cellar/libxml2/2.12.4/bin/xmllint
/usr/local/Cellar/libxml2/2.12.4/include/libxml2/ (46 files)
/usr/local/Cellar/libxml2/2.12.4/lib/libxml2.2.dylib
/usr/local/Cellar/libxml2/2.12.4/lib/cmake/libxml2/libxml2-config.cmake
/usr/local/Cellar/libxml2/2.12.4/lib/pkgconfig/libxml-2.0.pc
/usr/local/Cellar/libxml2/2.12.4/lib/python3.11/ (10 files)
/usr/local/Cellar/libxml2/2.12.4/lib/python3.12/ (10 files)
/usr/local/Cellar/libxml2/2.12.4/lib/libxml2.dylib
/usr/local/Cellar/libxml2/2.12.4/share/aclocal/libxml.m4
/usr/local/Cellar/libxml2/2.12.4/share/doc/ (68 files)
/usr/local/Cellar/libxml2/2.12.4/share/gtk-doc/ (54 files)
/usr/local/Cellar/libxml2/2.12.4/share/man/ (3 files)

/usr/local/Cellar/libxml2/2.12.4/bin/xmllint --version
/usr/local/Cellar/libxml2/2.12.4/bin/xmllint: using libxml version 21204

otool -L /usr/local/Cellar/libxml2/2.12.4/lib/libxml2.2.dylib
/usr/local/Cellar/libxml2/2.12.4/lib/libxml2.2.dylib:
	/usr/local/opt/libxml2/lib/libxml2.2.dylib (compatibility version 15.0.0, current version 15.4.0)
	/usr/lib/libz.1.dylib (compatibility version 1.0.0, current version 1.2.11)
	/usr/local/opt/icu4c/lib/libicui18n.73.dylib (compatibility version 73.0.0, current version 73.2.0)
	/usr/local/opt/icu4c/lib/libicuuc.73.dylib (compatibility version 73.0.0, current version 73.2.0)
	/usr/local/opt/icu4c/lib/libicudata.73.dylib (compatibility version 73.0.0, current version 73.2.0)
	/usr/lib/libiconv.2.dylib (compatibility version 7.0.0, current version 7.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1319.100.3)

/usr/local/bin/xmlsec1 --version                                                                                                       ─╯
xmlsec1 1.2.37 (openssl)

brew info libxmlsec1
/usr/local/Cellar/libxmlsec1/1.2.37

brew ls xmlsec1                                                                                                                        ─╯
/usr/local/Cellar/libxmlsec1/1.2.37/bin/xmlsec1
/usr/local/Cellar/libxmlsec1/1.2.37/bin/xmlsec1-config
/usr/local/Cellar/libxmlsec1/1.2.37/include/xmlsec1/ (40 files)
/usr/local/Cellar/libxmlsec1/1.2.37/lib/libxmlsec1-gcrypt.1.dylib
/usr/local/Cellar/libxmlsec1/1.2.37/lib/libxmlsec1-gnutls.1.dylib
/usr/local/Cellar/libxmlsec1/1.2.37/lib/libxmlsec1-openssl.1.dylib
/usr/local/Cellar/libxmlsec1/1.2.37/lib/libxmlsec1.1.dylib
/usr/local/Cellar/libxmlsec1/1.2.37/lib/pkgconfig/ (4 files)
/usr/local/Cellar/libxmlsec1/1.2.37/lib/ (9 other files)
/usr/local/Cellar/libxmlsec1/1.2.37/share/aclocal/xmlsec1.m4
/usr/local/Cellar/libxmlsec1/1.2.37/share/doc/ (150 files)
/usr/local/Cellar/libxmlsec1/1.2.37/share/man/ (2 files)



otool -L /usr/local/Cellar/libxmlsec1/1.2.37/lib/libxmlsec1.1.dylib                                                                    ─╯
/usr/local/Cellar/libxmlsec1/1.2.37/lib/libxmlsec1.1.dylib:
	/usr/local/opt/libxmlsec1/lib/libxmlsec1.1.dylib (compatibility version 4.0.0, current version 4.37.0)
	/usr/lib/libxslt.1.dylib (compatibility version 3.0.0, current version 3.26.0)
	/usr/local/opt/libxml2/lib/libxml2.2.dylib (compatibility version 13.0.0, current version 13.3.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1319.0.0)

The brew installed libxmlsec1 is using /usr/local/opt/libxml2/lib/libxml2.2.dylib which is also brew installed
version

After updating zshrc and re-installing requirements
export PATH="/usr/local/opt/libxml2/bin:$PATH"
source ~/.zshrc

pip uninstall lxml
pip install --no-binary lxml lxml==4.9.3




otool -L $(python -c "import xmlsec; print(xmlsec.__file__)")                                                                          ─╯
/Users/vinodpandey/Projects/saml-segfault/venv/lib/python3.10/site-packages/xmlsec.cpython-310-darwin.so:
	/usr/local/opt/libxmlsec1/lib/libxmlsec1-openssl.1.dylib (compatibility version 4.0.0, current version 4.37.0)
	/usr/local/opt/libxmlsec1/lib/libxmlsec1.1.dylib (compatibility version 4.0.0, current version 4.37.0)
	/usr/local/opt/openssl@1.1/lib/libcrypto.1.1.dylib (compatibility version 1.1.0, current version 1.1.0)
	/usr/lib/libxslt.1.dylib (compatibility version 3.0.0, current version 3.26.0)
	/usr/lib/libxml2.2.dylib (compatibility version 10.0.0, current version 10.9.0)
	/usr/lib/libz.1.dylib (compatibility version 1.0.0, current version 1.2.11)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1319.0.0)
	/usr/lib/libicucore.A.dylib (compatibility version 1.0.0, current version 70.1.0)

otool -L /usr/local/opt/libxmlsec1/lib/libxmlsec1.1.dylib                                                                              ─╯
/usr/local/opt/libxmlsec1/lib/libxmlsec1.1.dylib:
	/usr/local/opt/libxmlsec1/lib/libxmlsec1.1.dylib (compatibility version 4.0.0, current version 4.37.0)
	/usr/lib/libxslt.1.dylib (compatibility version 3.0.0, current version 3.26.0)
	/usr/local/opt/libxml2/lib/libxml2.2.dylib (compatibility version 13.0.0, current version 13.3.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1319.0.0)
	
	
brew info libxmlsec1
Required: gnutls ✘, libgcrypt ✔, libxml2 ✔, openssl@3 ✔

brew install gnutls
brew info libxmlsec1
Required: gnutls ✔, libgcrypt ✔, libxml2 ✔, openssl@3 ✔

------

brew uninstall libxmlsec1
brew uninstall libxml2

# install libxmlsec1 using below script becasuse the latest version gives error
export DESIRED_SHA="7f35e6ede954326a10949891af2dba47bbe1fc17"
wget -O /tmp/libxmlsec1.rb "https://raw.githubusercontent.com/Homebrew/homebrew-core/${DESIRED_SHA}/Formula/libxmlsec1.rb"
brew install --formula /tmp/libxmlsec1.rb

delete venv, create venv again and reinstall dependencies
pip install -r requirements.txt --no-cache-dir

python -c "import lxml.etree as etree;print(etree.LXML_VERSION);print(etree.LIBXML_VERSION);print(etree.LIBXML_COMPILED_VERSION);"
(4, 9, 3, 0)
(2, 10, 3)
(2, 10, 3)




```