include <MCAD/materials.scad>

deg=1;

//vxb linear motion rail
// http://www.vxb.com/page/bearings/PROD/12mmLinearMotionSystems/Kit8279
module rail(l=200)
{

d=12;
h=20.46;
e=17;
w=34;
//l=2000;
f=15;
t=4.5;
k=9.8;
j=15;
h1=6;
b=25;
n=50;
p=100;
s1=4.5;
s2=4; //M4 actually
union (){
    color(Aluminum) linear_extrude (height=l) union() {
        translate([-j/2, 0]) square([j, k]); //rail mount body
        translate([-w/2,0])  square([w, t]); //rail mount base
        polygon(points=[[j/3,k], [h1/2,f], [-h1/2,f], [-j/3,k]]); //j/3 because it doesn't quite line up
    }
    color(Stainless) linear_extrude(height=l) union () {
            translate([0, h]) circle(d/2); 
    }
	
}
}
//rail(304.8);
