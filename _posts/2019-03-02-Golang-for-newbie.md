---
layout: post  
title: Golang for newbie  
tags: Go Golang Linux  
---


### Intro  
Some golang stuff  
Mission: create cull pronetheus openstack exporter  



## basics  
### Set up Golang  
insert in the end of /root/.profile   
``export GOROOT=/opt/go/goroot
export GOPATH=/opt/go/go
export PATH=$PATH:/usr/local/bin:$GOPATH/bin``  
Make dirs  
``mkdir -p /opt/go/go /opt/go/goroot``  
Get Go  
``cd /opt/go/goroot  
curl -O https://storage.googleapis.com/golang/go1.11.2.linux-amd64.tar.gz
tar -xf go1.11.2.linux-amd64.tar.gz``  
Make test repo  
``mkdir -p /opt/go/go/src/github.com/user/hello``  
vim /opt/go/go/src/github.com/user/hello/hello.go  
``package main
import "fmt"
func main() {
    fmt.Printf("hello, world\n")
}``  
Setup env variables, check version and compile hello app  
``source /root/.profile  
go install github.com/user/hello
go version
$GOROOT/bin/hello``  
That's it!

### Date  
``time.Now()
today := time.Now().Weekday()``  
``t:= time.Now()
t.Hour()``   
### arrays  
``primes := [6]int{2, 3, 5, 7, 11, 13}  
var s []int = primes[1:4]``  

### struct  
``	s := []struct {
		i int
		b bool
	}{
		{2, true},
		{3, false},
		{5, true},
		{7, true},
		{11, false},
		{13, true},
	}
	fmt.Println(s)
  fmt.Printf("len=%d cap=%d %v\n", len(s), cap(s), s)``
create slice  
``b := make([]int, 0, 5) // len(b)=0, cap(b)=5``  
more slices of slice !  
``board := [][]string{
		[]string{"_", "_", "_"},
		[]string{"_", "_", "_"},
		[]string{"_", "_", "_"},
	}

	// The players take turns.
	board[0][0] = "X"  
  board[2][2] = "O"
  board[1][2] = "X"
  board[1][0] = "O"
  board[0][2] = "X"

  for i := 0; i < len(board); i++ {
  fmt.Printf("%s\n", strings.Join(board[i], " "))
}``  

### slices  
Get slice of array  
``s := [6]int{2, 3, 5, 7, 11, 13}
len``  
### Pointers  
pointer to a variable  
& - generate pointer  
\*p  - set value through pointer  
``i := 5
p := &i
fmt.Println(p) //5  
*p := 10
fmt.Println(i) //10  
but you cant use p := 50 (type int vs *int)``    

### Maps  
``type Vertex struct {
	Lat, Long float64
}

var m = map[string]Vertex{
	"Bell Labs": Vertex{
		40.68433, -74.39967,
	},
	"Google": Vertex{
		37.42202, -122.08408,
	},
}
//or
var m = map[string]Vertex{
	"Bell Labs": {40.68433, -74.39967},
	"Google":    {37.42202, -122.08408},
}

func main() {
	fmt.Println(m)
}``  
other example  
``	m := make(map[string]int)

	m["Answer"] = 42
	fmt.Println("The value:", m["Answer"])  
  delete(m, "Answer")  //0
  v, ok := m["Answer"]
	fmt.Println("The value:", v, "Present?", ok) //0 false
   ``  

### typeOf  
``package main
import (
	"fmt"
	"reflect"
)
func main() {
	var c, python, java = true, false, "no!"
	fmt.Println(i, j, c, python, reflect.TypeOf(java))
  //or  without reflect  
  fmt.Printf("Type: %T Value: %v\n", java, java)
}``  
## Http request / response  with JSON struct  
``import (
       "bytes"
       "net/http"
       "fmt"
       "reflect"
       "encoding/json"
       "net/http"
)

type Authjson struct {
    Auth Auth `json:"auth"`
}
type Auth struct {
    Methods  []string `json:"methods"`
}

func main() []string{
  data := Authjson{
      Auth: Auth{
        Methods: []string{"password"},
      }
  }

  url := "https://google.com"
  req, err := http.NewRequest("POST", url, bytes.NewBuffer(b))
  if err != nil {
        fmt.Println(err)
        log.Fatalln("Cannot encode auth json")
  }
  client := &http.Client{}
  resp, err := client.Do(req)
  if err != nil {
        panic(err)
    }
  defer resp.Body.Close()
  fmt.Printf("auth_resp", resp)

  return resp.Header["X-Subject-Token"]``

## Really random number  
``package main
import (
    "math/big"
    "crypto/rand"
    "fmt"
)
func main() {

  r, _ := rand.Int(rand.Reader, big.NewInt(80))
  fmt.Println("rand is:", r)
}``  

## Cycles  
``	for i := 0; i < 10; i++ {
		sum += i
	}``  
while  
``	for sum < 1000 {
		sum += sum
	}``  
infinite  
``	for {
	}``  

## Cases  and runtime OS  
``switch os := runtime.GOOS; os {
	case "darwin":
		fmt.Println("OS X.")
	case "linux":
		fmt.Println("Linux.")
	default:
		// freebsd, openbsd,
		// plan9, windows...
		fmt.Printf("%s.", os)
	}
}``

## Maps  
check that key exists  
``ok := mp[str[i]]
if ok == 0 {
	fmt.Println("not exist")
  } else {
  fmt.Println("exist")
}``  
