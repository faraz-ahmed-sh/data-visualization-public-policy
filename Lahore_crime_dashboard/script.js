

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


	//Make charts on which cross filter will be applied
	var charts = [
    makeBarChart()
        .dimension(crimeTypeDim)
        .group(crimeTypeGroup)
      .x(d3.scaleBand()
        .domain([0, 24])
        .rangeRound([0, 10 * 24])),
    makeBarChart()
        .dimension(monthDim)
        .group(monthGroup)
      .x(d3.scaleBand()
        .domain([-60, 150])
        .rangeRound([0, 10 * 21])),
    makeBarChart()
        .dimension(hourDim)
        .group(hourGroup)
      .x(d3.scaleLinear()
        .domain([0, 2000])
        .rangeRound([0, 10 * 40]))
  ];

  });

	// a bar chart function that uses the same properties for each of the chart
	// on which a cross filter is applied
	// source: https://github.com/square/crossfilter/blob/gh-pages/index.html
	function makeBarChart() {
    if (!makeBarChart.id) makeBarChart.id = 0;
    var margin = {top: 10, right: 10, bottom: 20, left: 10},
        x,
        y = d3.scaleLinear().range([100, 0]),
        id = makeBarChart.id++,
        axis = d3.axisTop(),
        brush = d3.brush(),
        brushDirty,
        dimension,
        group,
        round;
    function chart(div) {
      var width = x.range()[1],
          height = y.range()[0];
      y.domain([0, group.top(1)[0].value]);
      div.each(function() {
        var svg = d3.select(this),
            g = svg.select("g");
        // Create the skeletal chart.
        if (g.empty()) {
          svg.select(".title").append("a")
              .attr("href", "javascript:reset(" + id + ")")
              .attr("class", "reset")
              .text("reset")
              .style("display", "none");
          g = svg.append("svg")
              .attr("width", width + margin.left + margin.right)
              .attr("height", height + margin.top + margin.bottom)
            .append("g")
              .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
          g.append("clipPath")
              .attr("id", "clip-" + id)
            .append("rect")
              .attr("width", width)
              .attr("height", height);
          g.selectAll(".bar")
              .data(["background", "foreground"])
            .enter().append("path")
              .attr("class", function(d) { return d + " bar"; })
              .datum(group.all());
          g.selectAll(".foreground.bar")
              .attr("clip-path", "url(#clip-" + id + ")");
          g.append("g")
              .attr("class", "axis")
              .attr("transform", "translate(0," + height + ")")
              .call(axis);
          // Initialize the brush component with pretty resize handles.
          var gBrush = g.append("g").attr("class", "brush").call(brush);
          gBrush.selectAll("rect").attr("height", height);
          gBrush.selectAll(".resize").append("path").attr("d", resizePath);
        }
        // Only redraw the brush if set externally.
        if (brushDirty) {
          brushDirty = false;
          g.selectAll(".brush").call(brush);
          svg.select(".title a").style("display", brush.empty() ? "none" : null);
          if (brush.empty()) {
            g.selectAll("#clip-" + id + " rect")
                .attr("x", 0)
                .attr("width", width);
          } else {
            var extent = brush.extent();
            g.selectAll("#clip-" + id + " rect")
                .attr("x", x(extent[0]))
                .attr("width", x(extent[1]) - x(extent[0]));
          }
        }
        g.selectAll(".bar").attr("d", barPath);
      });
      function barPath(groups) {
        var path = [],
            i = -1,
            n = groups.length,
            d;
        while (++i < n) {
          d = groups[i];
          path.push("M", x(d.key), ",", height, "V", y(d.value), "h9V", height);
        }
        return path.join("");
      }
      function resizePath(d) {
        var e = +(d == "e"),
            x = e ? 1 : -1,
            y = height / 3;
        return "M" + (.5 * x) + "," + y
            + "A6,6 0 0 " + e + " " + (6.5 * x) + "," + (y + 6)
            + "V" + (2 * y - 6)
            + "A6,6 0 0 " + e + " " + (.5 * x) + "," + (2 * y)
            + "Z"
            + "M" + (2.5 * x) + "," + (y + 8)
            + "V" + (2 * y - 8)
            + "M" + (4.5 * x) + "," + (y + 8)
            + "V" + (2 * y - 8);
      }
    }
    brush.on("brush.chart", function() {
      var svg = d3.select(this.parentNode.parentNode.parentNode);
      svg.select(".title a").style("display", null);
    });
    brush.on("brush.chart", function() {
      var g = d3.select(this.parentNode),
          extent = brush.extent();
      if (round) g.select(".brush")
          .call(brush.extent(extent = extent.map(round)))
        .selectAll(".resize")
          .style("display", null);
      g.select("#clip-" + id + " rect")
          .attr("x", x(extent[0]))
          .attr("width", x(extent[1]) - x(extent[0]));
      dimension.filterRange(extent);
    });
    brush.on("brush.chart", function() {
      if (brush.empty()) {
        var svg = d3.select(this.parentNode.parentNode.parentNode);
        svg.select(".title a").style("display", "none");
        svg.select("#clip-" + id + " rect").attr("x", null).attr("width", "100%");
        dimension.filterAll();
      }
    });
    chart.margin = function(_) {
      if (!arguments.length) return margin;
      margin = _;
      return chart;
    };
    chart.x = function(_) {
      if (!arguments.length) return x;
      x = _;
      axis.scale(x);
      brush.x(x);
      return chart;
    };
    chart.y = function(_) {
      if (!arguments.length) return y;
      y = _;
      return chart;
    };
    chart.dimension = function(_) {
      if (!arguments.length) return dimension;
      dimension = _;
      return chart;
    };
    chart.filter = function(_) {
      if (_) {
        brush.extent(_);
        dimension.filterRange(_);
      } else {
        brush.clear();
        dimension.filterAll();
      }
      brushDirty = true;
      return chart;
    };
    chart.group = function(_) {
      if (!arguments.length) return group;
      group = _;
      return chart;
    };
    chart.round = function(_) {
      if (!arguments.length) return round;
      round = _;
      return chart;
    };

    brush.on = function() {
    var value = chart.on.apply(chart, arguments);
    return value === chart ? brush : value;
  };

    return brush;
};