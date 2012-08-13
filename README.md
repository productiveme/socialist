# Socialist - sharing a generic list with friends

A fork of the [leaderboard-coffeescript](https://github.com/srackham/leaderboard-coffeescript) project which is a port of [Meteor](http://meteor.com/) framework's [Leaderboard example](http://meteor.com/examples/leaderboard) rewritten using [CoffeeScript](http://coffeescript.org/), [Less](http://lesscss.org/) and Twitter [Bootstrap](http://twitter.github.com/bootstrap/).

This port has been enhanced with Bootstrap styling, a drop-down menu and tooltips. You can also add and delete players, reset the data and sort players by name and score.  The changes to the original example reflect these enhancements.  I've made use of the jQuery `$.extend()` API to soak up repetitive template property assignments.

## Installation
To install create a meteor project and clone this repo into it (you have to move the `.meteor` directory out temporarily else git refuses to clone). You also need to install the Meteor jquery package and compile the CoffeeScript and Less files

    meteor create socialist
    rm socialist/*
    mv socialist/.meteor/ /tmp
    git clone git@github.com:productiveme/socialist.git
    mv /tmp/.meteor/ socialist/
    cd socialist/
    meteor add jquery
    coffee -c socialist.coffee
    lessc client/socialist.less client/socialist.css

To start the project in the built-in Meteor server:

    meteor
