%Testing Random Waypoint mobility model.
clear all;clc;close all;

s_input = struct('V_POSITION_X_INTERVAL',[-100 100],...%(m)
                 'V_POSITION_Y_INTERVAL',[-100 100],...%(m)
                 'V_SPEED_INTERVAL',[1 1],...%(m/s)
                 'V_PAUSE_INTERVAL',[0 0],...%pause time (s)
                 'V_WALK_INTERVAL',[1.00 180.00],...%walk time (s)
                 'V_DIRECTION_INTERVAL',[-180 180],...%(degrees)
                 'SIMULATION_TIME',500,...%(s)
                 'NB_NODES',100);
s_mobility = Generate_Mobility(s_input);



timeStep = 0.1;%(s)
test_Animate(s_mobility,s_input,timeStep);