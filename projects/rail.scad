deg=pi/180;

//vxb linear motion rail
// http://www.vxb.com/page/bearings/PROD/12mmLinearMotionSystems/Kit8279
d=12;
h=20.46;
theta=20*deg; //guesstimate
e=17;
w=34;
l=200; //actually 2000
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
linear_extrude (height = l){  
    union() {
        translate([-j/2, 0]) square([j, k]); //rail mount body
        translate([-w/2,0])  square([w, t]); //rail mount base
        translate([0,f]) rotate(180*deg-theta) translate([-h1/2]) square([h1, f-t]); //should do this with a polygon instead
        translate([0,f]) rotate(180*deg+theta) translate([-h1/2]) square([h1, f-t]); //mirror doesnt work?
        translate([0, h]) circle(d/2); 
	
    }
}
