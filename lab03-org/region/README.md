# Region

Creates an address pool in an individual region.

This is required as pools with resources require them to be region based and the org level pool is regionless.

The ideal method would be to create a pool per deployment, however you cannot delegate permissions to create
child pools via RAM.
