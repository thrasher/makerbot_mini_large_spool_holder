$fs = 0.1; // mm per facet in cylinder
$fa = 1; // degrees per facet in cylinder
$fn = 150; // higher values give a smoother surface

spool_hole_dia = 2.25; // inches for Shaxon PLA filament spool
//spool_hole_dia = 2.09; // inches for Makerbot small PLA filament spool
//spool_hole_dia = 1.25; // inches for MG Chemicals PLA filament spool

spool_height = 3; // thickness of the spool
spool_hub_wall = 0.2; // wall thickness of spool hub
spool_dia = 9; // outer diameter of the spool
spool_curb_width = .25; // width of curbs at edge of spool, that keep spool aligned.
spool_curb_height = .2; // height of curbs
hanger_thickness = 0.25; // thickness of bracket over side of makerbot mini

overcut = 1; // distance to over-cut beyond the part
module spool_cuts() {
    translate([spool_hole_dia*.45, -spool_hole_dia/2, -overcut]) cube([overcut, spool_hole_dia, spool_height+spool_curb_width+2*overcut]);    
    translate([-(spool_hole_dia*.45)-overcut, -spool_hole_dia/2, -overcut]) cube([overcut, spool_hole_dia, spool_height+spool_curb_width+2*overcut]);
    translate([-(spool_hole_dia/2), spool_hole_dia*.2-spool_hole_dia,  -overcut]) cube([spool_hole_dia, spool_hole_dia, spool_height+spool_curb_width+2*overcut]);
}
module arm() {
    difference() {
        union() {
            cylinder(h=spool_height+spool_curb_width*2, d=spool_hole_dia);
            cylinder(h=spool_curb_width, r=spool_hole_dia/2+spool_curb_height);
            translate([0, 0, spool_height+spool_curb_width*2])
                rotate_extrude(angle = 360, convexity = 10) translate([spool_hole_dia/2-0.08, 0, 0]) circle(d = spool_curb_width);
        }
        translate([0, 0, -.5]) cylinder(h=spool_height+spool_curb_width*2+2*overcut, r=(spool_hole_dia/2-spool_hub_wall));
        spool_cuts();
    }

    // spool support triangle
    triangle_points =[
        [0, spool_hole_dia/2-spool_hub_wall],
        [spool_height+spool_curb_width*2, spool_hole_dia/2-spool_hub_wall],
//        [spool_height+spool_curb_width, spool_hole_dia*.2],
        [0, 0]
    ];
    triangle_paths =[[0,1,2,3]];
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
        hanger_tab(0);
    }
}

module  hanger_tab(margin) {
    tab_points = [
        [spool_hole_dia*.45, spool_hole_dia + margin],
        [spool_hole_dia * .45 - spool_hole_dia * .3 - margin, spool_hole_dia + margin],
        [spool_hole_dia * .45 - spool_hole_dia * .2 - margin, spool_hole_dia*.7 + margin],
        [-(spool_hole_dia * .45 - spool_hole_dia * .2 - margin), spool_hole_dia*.7 + margin],
        [-(spool_hole_dia * .45 - spool_hole_dia * .3 - margin), spool_hole_dia + margin],
        [-spool_hole_dia*.45, spool_hole_dia + margin],
        [-spool_hole_dia*.45, 5],
        [spool_hole_dia*.45, 5]
    ];
    tab_paths = [[0,1,2,3,4,5,6,7]];
    translate([0, 0, -hanger_thickness])
        linear_extrude(height = hanger_thickness, center = false, convexity = 10, twist = 0, slices = 20, scale = 1.0) 
            polygon(tab_points, tab_paths, convexity = 10);
}

mini_edge_thickness = .12;
mini_wall_thickness = mini_edge_thickness/2;
tab_points = [
    [(9-spool_hole_dia)/2 - 1,0],
    [(9-spool_hole_dia)/2 + hanger_thickness, 0],
    [(9-spool_hole_dia)/2 + hanger_thickness, -hanger_thickness*2 - mini_wall_thickness],
    [(9-spool_hole_dia)/2 - 1,                -hanger_thickness*2 - mini_wall_thickness],
    [(9-spool_hole_dia)/2 - 1, -hanger_thickness - mini_wall_thickness],
    [(9-spool_hole_dia)/2, -hanger_thickness - mini_wall_thickness],
    [(9-spool_hole_dia)/2, -hanger_thickness + mini_wall_thickness],
    [(9-spool_hole_dia)/2 - .62, -hanger_thickness + mini_wall_thickness],
    [(9-spool_hole_dia)/2 - .62, -hanger_thickness],
    [(9-spool_hole_dia)/2 - 1, -hanger_thickness]
];
tab_paths = [[0,1,2,3,4,5,6,7,8,9,10]];

module hook() {
    margin = 0.02; // TODO: play with this value to get a tight fit (0.05 is too large a Makerbot Mini)
    hanger_tab(margin);
    
    translate([0, spool_hole_dia+margin, 0])
    rotate([90, 0, 90])
    linear_extrude(height = spool_hole_dia*.45*2, center = true, convexity = 10, twist = 0, slices = 20, scale = 1.0) 
            polygon(tab_points, tab_paths, convexity = 10);
}

module plug() {
    pwidth = 0.4;
    translate([-spool_dia/2, spool_hole_dia, 0])
            difference() {
                rotate([90, 0, 90])
                union() {
                    linear_extrude(height = pwidth, center = false, convexity = 10, twist = 0, slices = 20, scale = 1.0) 
                            polygon(tab_points, tab_paths, convexity = 10);
                    translate([(9-spool_hole_dia)/2 + hanger_thickness-pwidth, 0, 0]) cube([pwidth, pwidth ,pwidth]);
                }
                rotate([270, 0, 0])
                    translate([pwidth/2, -pwidth/2, 0]) {
                        cylinder (h = 5, d=0.1);
                        translate([0, 0, (9-spool_hole_dia)/2 + hanger_thickness - pwidth/2]) cylinder (h = 2, d=0.17);
                    }
            }
}

// These parts are needed, and should be exported as STL separately from OpenSCAD
plug();
hook();
arm();