#!/bin/zsh

# Generate UML source file
swiftplantuml classdiagram "../BikeRide/BikeRide/Common" --output consoleOnly > BikeRideCommon.txt
swiftplantuml classdiagram "../BikeRide/BikeRide/BikeRide/BikeRideApp.swift" "../BikeRide/BikeRide/BikeRide/Model" --output consoleOnly > BikeRideModel.txt
swiftplantuml classdiagram "../BikeRide/BikeRide/BikeRide WatchKit Extension/BikeRideWatchApp.swift" "../BikeRide/BikeRide/BikeRide WatchKit Extension/Model" --output consoleOnly > BikeRideWatchModel.txt

# Add pragma to disable graphviz engine and use internal one from plantuml
sed -i .org -r "s/STYLE END/STYLE END\n!pragma layout smetana/g" BikeRideCommon.txt
sed -i .org -r "s/STYLE END/STYLE END\n!pragma layout smetana/g" BikeRideModel.txt
sed -i .org -r "s/STYLE END/STYLE END\n!pragma layout smetana/g" BikeRideWatchModel.txt

# Generate the svg based on the umltext
java -DPLANTUML_LIMIT_SIZE=8192 -jar plantuml.1.2021.10.jar BikeRideCommon.txt -tsvg
java -DPLANTUML_LIMIT_SIZE=8192 -jar plantuml.1.2021.10.jar BikeRideModel.txt -tsvg
java -DPLANTUML_LIMIT_SIZE=8192 -jar plantuml.1.2021.10.jar BikeRideWatchModel.txt -tsvg
