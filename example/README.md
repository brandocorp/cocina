# Instructions

## Install

Install the Cocina gem in your preferred ruby.

### Example: ChefDK

```
chef gem install cocina
```

### Example: RVM

```
rvm use ruby@cocina --create
gem install cocina
```

## Converge

```
cocina web-ubuntu-1404
```

You should see output like the following:

```
-----> Running for: web-ubuntu-1404
       Dependencies: ["db-ubuntu-1404", "app-ubuntu-1404"]
```
