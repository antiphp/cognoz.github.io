# Working with slice of maps
package main

import (
	"fmt"
)

func main() {
        type tgt map[string]interface{}
        targets := [2]tgt{}
        dic := tgt{
          "name": "tst",
          "kek": "lkek",
        }
        targets[0] = dic
        targets[1] = dic
	fmt.Println(dic)
	fmt.Println(targets)
}
