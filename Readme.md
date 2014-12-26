##Run

```docker pull aybarscengaver/ojs```
```docker run --name ojsserver -d -p 80:80 -p 3306:3306 -p 27017:27017 -v ~/www/ojs/www:/var/www okulbilisim/ojs```
##Build

  git clone git@github.com:okulbilisim/ojs-docker
	cd ojs-docker
	docker build -t="okulbilisim/ojsdocker" ./

Ps: Project root directory must be on parent directory in www dir.

