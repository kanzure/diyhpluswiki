use <rail.scad>;
use <truck.scad>
inch = 25.4;

plate_width=300;
plate_length=200;
plate_thickness=1/4*inch;
rail_width=34; //get this from rail.scad ... sigh.
rail_center_height=20.46; //this too
truck_length=36;  //sigh. is introspection too much to ask?
y_carriage_width = plate_length/2;
x_carriage_width = plate_width/2;

module slide(length, carriage_length, trucks=2){union(){
    rail(length);
    if (trucks == 2) { union(){
        translate([0, rail_center_height, truck_length/2]) truck();
        translate([0, rail_center_height, carriage_length-truck_length/2]) truck();}}
    else if (trucks ==1) { translate([0, rail_center_height, carriage_length/2]) truck();}
}
}


module xy_table() union(){
    cube([plate_width, plate_length, plate_thickness]);   
    union(){//x axis
        translate([0, rail_width/2, 0]) rotate(a=[90,180,90]) slide(plate_width, x_carriage_width, trucks=1);
        translate([0, plate_length-rail_width/2, 0]) rotate(a=[90,180,90]) slide(plate_width, x_carriage_width);
    }
    union(){//y axis
        translate([rail_width/2, plate_length, plate_thickness]) rotate(a=[90,0,0]) slide(plate_length, y_carriage_width, trucks=1);
        translate([plate_width-rail_width/2, plate_length, plate_thickness]) rotate(a=[90,0,0]) slide(plate_length, y_carriage_width);
    }


translate([0,0,0]) for (i = [0:1]){
}


}xy_table();
