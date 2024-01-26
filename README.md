# Introduction

Sample project for replicating segmentation fault error in allauth saml integration. https://mocksaml.com/
is configured as Identity provider for testing.

We have added below code in `manage.py` to output logs for segfault

```
import faulthandler
faulthandler.enable()
```

## Setup
Python version for below setup is `3.10.12`
```
python -V                                                                                                                        ─╯
Python 3.10.12

```

```
git clone https://github.com/vinodpandey/saml-allauth-demo.git
cd saml-allauth-demo

python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

```

## Testing
- Run django server. sqlite database is already included in the repository. There is no need to run
migrations
```
python manage.py runserver
```  
- access `http://localhost:8000` and click on `SSO Login`. This will redirect to https://mocksaml.com/ IdP 
authentication page. Click on `Sign In` and it will redirect back our home page.
- Click on `Logout` button.
- Repeat above 2 steps for approx 10 times. The segfault occurs for me after 4-5 tries.

