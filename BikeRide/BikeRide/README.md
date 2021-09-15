#  BikeRide

* [Ride Simulation](RideSimuation)

Use gpsbabel to convert gpx files into the Apple iOS gpx format. Apple only accepts waypoints with optional time.

// 5 meter per seconds equals about 20 km/h
gpsbabel -i gpx -f input.gpx -x interpolate,distance=5m -o gpx -F route_5ms.gpx

// Create fake timestamps for every track point
gpsbabel -i gpx -f route_5ms.gpx -x track,faketime=f20210904101112+1 -o gpx -F route_time.gpx

// Transform to waypoints for xcode gps simulator
gpsbabel -i gpx -f route_time.gpx -x transform,wpt=trk -o gpx -F route_simulation.gpx




