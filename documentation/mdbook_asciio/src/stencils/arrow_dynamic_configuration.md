# Wirl arrow dynamic configuration

The wirl arrow can be dynamically configured by using the keyboard bindings. Some configuration can be done via the popup menus but we are working eliminating them in favor of keyboard bindings.

The keyboard bindings can have changed, best is to check them in the default_bindings.pl configuration file.

You can also define your own bindings.

## Changing the arrow type

***binding:*** << e >> + << w >> + chose the arrow type

## Controlling the connectors

***binding:*** << a >> + chose the connection command

- start enable connection     
- start disable connection    
- end enable connection       
- end disable connection      
                               
- enable diagonals            
- disable diagonals           
                               
- Start flip enable connection
- End flip enable connection  
                              
## changing the arrow connector

***binding:*** << a >> + << c >> + (<< s >> or << e >>) + chose the arrow connector

- << a >>     group 'arrow'
- << c >> sub group 'connector'
- << s >> sub group 'start_connector'
- << e >> sub group 'end_connector'


### fixed connector shape

A single character will be used as the connector regardless of the arrow geometry

### dynamic connector shape

A set of character that will be used depending on the arrow geometry

```text
 RIGHT  DOWN  LEFT  UP   
['-',   '|',  '-',  '|'] ],
```

