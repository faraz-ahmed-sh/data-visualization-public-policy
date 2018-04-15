

var margin = 50;
var width = 720;
var height = 450;

//spacing properties of legend
var legendRectSize = 18;                            
var legendSpacing = 4;

//load the data
d3.json("dengue_age.json", function(error, data) {

	if (error) throw error;

	var data = data.filter(filterCriteria);
	// filter the data as the last two rows are redundant for the purpose of this assignment.
	function filterCriteria(d) {
	    return (d["Towns name"] != "Total no.") && (d["Towns name"] != "Prevelance(%)");
	}

	data.forEach( function(d) {
		// unary+ operator to read numerical data correctly.
		d["01-10"] = +d["01-10yrs."] || 0
		d["11-20"] = +d["11-20yrs."] || 0
		d["21-30"] = +d["21-30yrs."] || 0
		d["31-40"] = +d["31-40yrs."] || 0
		d["41-50"] = +d["41-50yrs."] || 0
		d["51-60"] = +d["51-60yrs."] || 0
		d["61-70"] = +d["61-70yrs."] || 0
		d["71-80"] = +d["71-80yrs."] || 0
		d["81-90"] = +d["81-90yrs."] || 0
		d["91-100"] = +d["91-100yrs."] || 0
		d["Unknown"] = +d["Unknown"] || 0
		d["Total"] = +d["Total"] || 0

	});

	//sort the data according to the lowest total number of people with dengue fever
	//in each neighborhood

	data.sort(function(a, b) { return a["Total"] - b["Total"]; });
	
	dataset = data;
	makeBarChart(dataset);
	
});

function makeBarChart(dataset) {

	//create a series of stacks/keys for the stacked bar chart for a limited set of categories
	var series = d3.stack()
    .keys(["01-10", "11-20", "21-30", "31-40", "41-50", "51-60", "61-70"])
    .offset(d3.stackOffsetDiverging)
    (dataset);

	//add the SVG element
	var svg = d3.select("#chart")
		.append('svg') 
		.attr('width', width + margin*2)
		.attr('height', height + margin*3);

	// set the domains of X and Y axes
	var xScale = d3.scaleBand()
		.domain(dataset.map(function (d) { return d["Towns name"]; }))
		.rangeRound([0, width])
		.paddingInner(0.4)
		.align(0.1);

	var yScale = d3.scaleLinear()
		.domain([d3.min(series, stackMin), d3.max(series, stackMax)])
		.rangeRound([0, height]);

	//var zScale = d3.scaleOrdinal(d3.schemeCategory10);

	var zScale = d3.scaleOrdinal()
	.range(["#12719e", "#1696d2", "#636363", "#46abdb", "#a2d4ec", "#73bfe2", "#a2d4ec"]);

	var g = svg.append('g')
	.attr('transform', 'translate(' + margin + ',' + (margin*2.5) + ')');
	
	var xAxis = svg.append('g')
		.attr('transform', 'translate(' + margin + ',' + (margin*2.5) + ')')
		.call(d3.axisTop(xScale))
		.selectAll("text")
		.attr("dx", "15")
		.attr("dy", "-.5em")
		.attr("transform", "rotate(-20)" );

	var yAxis = svg.append('g')
		.attr('transform', 'translate(' + margin + ',' + (margin*2.5) + ')')
		.call(d3.axisLeft(yScale));

	 //add x and y axis labels              
     svg.append("text")    
	    .attr("transform", "translate(" + (width/1.8) + " ," + (margin+30) + ")")
	    .style("text-anchor", "middle")
	    .attr("font-weight", "bold")
	    .text("Neighborhood");

	svg.append("text")
	    .attr("transform", "rotate(-90)")
	    .attr("x", -margin*9)
	    .attr("y", margin/4)
	    .attr("font-weight", "bold")
	    .text("Number of people with dengue");

	//add title and subtitle
	svg.append("text")
        .attr("x", (width/1.8))             
        .attr("y", (margin / 2))
        .attr("text-anchor", "middle")  
        .style("font-size", "30px") 
        //.font(sans-serif")
        .text("High prevelance of dengue among young adults in Lahore");

    svg.append("text")
        .attr("x", (width/2.15))             
        .attr("y", (margin))
        .attr("text-anchor", "middle")  
        .style("font-size", "20px") 
        .text("Based on the survey conducted in 18 hospitals in Lahore in 2011-2012");

	// add the data to the bar	chart
	var barchart = g.selectAll(".barchart")
		.data(series) 
		.enter().append("g")
		.attr("fill", function(d) { return zScale(d.key); })
		.selectAll("rect")
		.data(function(d) { return d; })
		.enter().append("rect")
		
		.attr("class", "barchart") // now you're making sure that the class that you're choosing is barchartsource:
		.attr("x", function(d) { return xScale(d.data["Towns name"]); })
		.attr("width", "45")
		.attr("y", function(d) { return yScale(d[0]); })
		.attr("height", function(d) { return -(yScale(d[0]) - yScale(d[1])); })

		//add the mouseover tooltip
		.on("mouseover", function() { tooltip.style("display", null); })
		.on("mouseout", function() { tooltip.style("display", "none"); })
		.on("mousemove", function(d) {
		    var xPosition = d3.mouse(this)[0] + (margin-15);
		    var yPosition = d3.mouse(this)[1] + (margin*2);
		    tooltip.attr("transform", "translate(" + xPosition + "," + yPosition + ")");
		    tooltip.select("text").text(d[1]-d[0])});

	//define min and max values for the series of stacks ("1-10", "11-20." etc.)
	function stackMin(serie) {
	  return d3.min(serie, function(d) { return d[0]; });
	}

	function stackMax(serie) {
	  return d3.max(serie, function(d) { return d[1]; });
	}

	//preparing the legend
	var dataL = 5;
	var offset = 60; // for spacing of the legend bars

	var legend = svg.selectAll('.legend')                     
      .data(zScale.domain())                                   
      .enter()                                             
      .append('g')                                       
      .attr('class', 'legend')                           
      .attr('transform', function(d, i) { 
         var newdataL = dataL
         dataL +=  d.length + offset
         return "translate(" + (newdataL)  + ")"    });

    legend.append('rect')                               
      .attr('width', 15)                     
      .attr('height', 15)
      .attr("x", margin*2.4)
      .attr("y", height+margin)                
      .style('fill', zScale)                          
      .style('stroke', zScale);                     

    legend.append('text')                        
      .attr('x', (margin)*2.8)          
      .attr('y', height+margin+11)          
      .text(function(d) { return d; }); 

  	//adding text above the legend labels
    svg.append("text")
        .attr("x", (width/2.0))             
        .attr("y", (height+40))
        .attr("text-anchor", "middle")  
        .style("font-size", "15px") 
        .attr("font-weight", "bold")
        .text("Age groups"); 

	 // preparing the tooltip.
	var tooltip = svg.append("g")
		.attr("class", "tooltip")
		.style("display", "none");

	tooltip.append("rect")
		.attr("width", 30)
		.attr("height", 20)
		.attr("fill", "white")
		.style("opacity", 0.5);

	tooltip.append("text")
		.attr("x", 15)
		.attr("dy", "1.2em")
		.style("text-anchor", "middle")
		.attr("font-size", "12px")
		.attr("font-weight", "bold");

};