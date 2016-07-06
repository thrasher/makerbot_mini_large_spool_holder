$fs = 0.1; // mm per facet in cylinder
$fa = 5; // degrees per facet in cylinder
$fn = 500; // higher values give a smoother surface

spool_hole_dia = 2.25; // inches for Shaxon PLA filament spool
//spool_hole_dia = 2.09; // inches for Makerbot small PLA filament spool
//spool_hole_dia = 1.25; // inches for MG Chemicals PLA filament spool
spool_hub_wall = 0.2; // wall thickness of spool hub
spool_height = 3; // thickness of the spool
spool_dia = 9; // outer diameter of the spool
hanger_thickness = 0.25; // thickness of bracket over side of makerbot mini

overcut = 1; // distance to over-cut beyond the part
module spool_cuts() {
    translate([spool_hole_dia*.45, -spool_hole_dia/2, -overcut]) cube([overcut,spool_hole_dia,  spool_height+2*overcut]);    
    translate([-(spool_hole_dia*.45)-overcut, -spool_hole_dia/2, -overcut]) cube([overcut, spool_hole_dia, spool_height+2*overcut]);
    translate([-(spool_hole_dia/2),spool_hole_dia*.2 - spool_hole_dia,  -overcut]) cube([spool_hole_dia, spool_hole_dia, spool_height+2*overcut]);
}
module arm() {
    difference() {
        cylinder(h=spool_height+spool_hub_wall, d=spool_hole_dia);
        translate([0, 0, -.5]) cylinder(h=spool_height+1, r=(spool_hole_dia/2-spool_hub_wall));
        spool_cuts();
    }

    // spool support triangle
    triangle_points =[[0,spool_hole_dia/2-spool_hub_wall/2],[spool_height,spool_hole_dia/2-spool_hub_wall/2],[0,0]];
    triangle_paths =[[0,1,2]];
    rotate([0,270,0])
        linear_extrude(height = spool_hub_wall, center = true, convexity = 10, twist = 0, slices = 20, scale = 1.0) 
        polygon(triangle_points, triangle_paths, convexity = 10);

    // spool wall plate
    plate_points =[
        [-spool_hole_dia*.45, spool_hole_dia*.2],
        [-spool_hub_wall/2,0], [spool_hub_wall/2,0],
        [spool_hole_dia*.45, spool_hole_dia*.2],
        [spool_hole_dia*.45, spool_hole_dia],
        [-spool_hole_dia*.45, spool_hole_dia]
    ];
    plate_paths =[[0,1,2,3,4,5]];
    difference() {
        translate([0, 0, -hanger_thickness]) 
            linear_extrude(height = hanger_thickness, center = false, convexity = 10, twist = 0, slices = 20, scale = 1.0) 
                polygon(plate_points, plate_paths, convexity = 10);
        hanger_tab();
    }
}

module spool_tab() {
    difference() {
        translate([0,0,spool_height])
        difference() {
            cylinder(h=spool_hub_wall*2, r=spool_hole_dia/2+spool_hub_wall);
            spool_cuts();
        }
        scale([1.0, 1.0, 1.0]) arm();
    }
}

module  hanger_tab() {
    tab_points = [
        [spool_hole_dia*.45, spool_hole_dia],
        [spool_hole_dia * .45 - spool_hole_dia * .3, spool_hole_dia],
        [spool_hole_dia * .45 - spool_hole_dia * .2, spool_hole_dia*.7],
        [-(spool_hole_dia * .45 - spool_hole_dia * .2), spool_hole_dia*.7],
        [-(spool_hole_dia * .45 - spool_hole_dia * .3), spool_hole_dia],
        [-spool_hole_dia*.45, spool_hole_dia],
        [-spool_hole_dia*.45, 3],
        [spool_hole_dia*.45, 3]
    ];
    tab_paths = [[0,1,2,3,4,5,6,7]];
    translate([0, 0, -hanger_thickness])
        linear_extrude(height = hanger_thickness, center = false, convexity = 10, twist = 0, slices = 20, scale = 1.0) 
            polygon(tab_points, tab_paths, convexity = 10);
}
module hanger() {
    hanger_tab();
    mini_edge_thickness = .12;
    mini_wall_thickness = mini_edge_thickness/2;
    
    tab_points = [
        [0,0],
        [(9-spool_hole_dia)/2 + hanger_thickness, 0],
        [(9-spool_hole_dia)/2 + hanger_thickness, -hanger_thickness*2 - mini_wall_thickness],
        [(9-spool_hole_dia)/2 - 1,                -hanger_thickness*2 - mini_wall_thickness],
        [(9-spool_hole_dia)/2 - 1, -hanger_thickness - mini_wall_thickness],
        [(9-spool_hole_dia)/2, -hanger_thickness - mini_wall_thickness],
//        [(9-spool_hole_dia)/2 -.62, -hanger_thickness - mini_edge_thickness],
//        [(9-spool_hole_dia)/2, -hanger_thickness ],
        [(9-spool_hole_dia)/2, -hanger_thickness + mini_wall_thickness],
        [(9-spool_hole_dia)/2 - .62, -hanger_thickness + mini_wall_thickness],
        [(9-spool_hole_dia)/2 - .62, -hanger_thickness],
        [0,-hanger_thickness]
    ];
    tab_paths = [[0,1,2,3,4,5,6,7,8,9,10]];
    translate([0, spool_hole_dia, 0])
    rotate([90, 0, 90])
    linear_extrude(height = spool_hole_dia*.45*2, center = true, convexity = 10, twist = 0, slices = 20, scale = 1.0) 
            polygon(tab_points, tab_paths, convexity = 10);
}

// These parts are needed, and should be exported as STL separately from OpenSCAD
hanger();
spool_tab();
arm();