

var margin = 50;
var width = 720;
var height = 450;

//load the data
d3.json("Data/lahore_crime_14.json", function(error, data) {

	if (error) throw error;

	data.forEach( function(d) {
		// unary+ operator to read numerical data correctly.
		//d["01-10"] = +d["01-10yrs."] || 0
		//d["Time"] = d3.dateFormat.parse(d["Time"]) || 0
		d["year"] = +d["year"] || 0
		d["Month"] = +d["Month"] || 0
		d["hour"] = +d["hour"] || 0
	});

	dataset = data;
	//makeBarChart(dataset);
	console.log(dataset);
	


	//Create a Crossfilter instance
	var ndx = crossfilter(dataset);
	//console.log(ndx)

	//Define Dimensions
	var crimeTypeDim = ndx.dimension(function(d) { return d["Crime Type"]; });
	var monthDim = ndx.dimension(function(d) { return d["Month"]; });
	var hourDim = ndx.dimension(function(d) { return d["hour"]; });
	var allDim = ndx.dimension(function(d) {return d;});


	//Group Data
	var crimeTypeGroup = crimeTypeDim.group();
	var monthGroup = monthDim.group();
	var hourGroup = hourDim.group();
	var all = ndx.groupAll();

});