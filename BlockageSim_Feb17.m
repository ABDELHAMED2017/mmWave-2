% BlockageSim_Feb19
% Random Way-point mobility model for blockers
% Simulating Blockage of nT number of APs.
% Generate time sequence of blocked/unblocked periods

close all;
clear;

%----Play-with-values---------------------------------------
V=1; %velocity m/s
hb = 1.8;
hr = 1.4;
ht = 6;

R=100; %m Radius
rho_b = 0.01;%0.65;%Rajeev calculated central park
nB = 4*R^2*rho_b;%=4000; %number of blokers
nT = 2; %number of APs
simTime = 60*60; %sec Total Simulation time 
tstep = 0.01; %(sec) time step
mu = 5; %Expected bloc dur =1/mu
%------------------------------------------------------

frac = (hb-hr)/(ht-hr);
temp = 2/pi*rho_b*V*frac;
rT = R*sqrt(rand(nT,1)); %location of APs
alphaT = 2*pi*rand(nT,1);%location of APs
xT = rT.*cos(alphaT);%location of APs
yT = rT.*sin(alphaT);%location of APs
% data = cell(nB,nT); %contans timestamp of blockage of all APs by all blockers
dataAP = cell(nT,1); %contain array of timestamps for all APs no matter which blocker

s_input = struct('V_POSITION_X_INTERVAL',[-R R],...%(m)
    'V_POSITION_Y_INTERVAL',[-R R],...%(m)
    'V_SPEED_INTERVAL',[V V],...%(m/s)
    'V_PAUSE_INTERVAL',[0 0],...%pause time (s)
    'V_WALK_INTERVAL',[1.00 60.00],...%walk time (s)
    'V_DIRECTION_INTERVAL',[-180 180],...%(degrees)
    'SIMULATION_TIME',simTime,...%(s)
    'NB_NODES',nB);
s_mobility = Generate_Mobility(s_input);




for indB = 1:nB %for every blocker
    for iter =1:(length(s_mobility.VS_NODE(indB).V_POSITION_X)-1)
        % for every time blocker changes direction
        loc0 = [s_mobility.VS_NODE(indB).V_POSITION_X(iter);...
            s_mobility.VS_NODE(indB).V_POSITION_Y(iter)];
        loc1 = [s_mobility.VS_NODE(indB).V_POSITION_X(iter+1);...
            s_mobility.VS_NODE(indB).V_POSITION_Y(iter+1)];
        start_time = s_mobility.VS_NODE(indB).V_TIME(iter);
        velocity = sqrt((s_mobility.VS_NODE(indB).V_SPEED_X(iter))^2+ ...
            (s_mobility.VS_NODE(indB).V_SPEED_Y(iter))^2);
        for indT = 1:nT %for every AP
            locT = [xT(indT);yT(indT)];
            
            distance_travelled = find_blockage_distance([loc0,loc1],locT,alphaT(indT));
            timeToBl = distance_travelled/velocity; %time to blocking event
            timestampBl = start_time+timeToBl; %timestamp of blockage event
            if(distance_travelled>=0 && timestampBl<=simTime)
%                 data{indB,indT} = [data{indB,indT},start_time+blockage_time];
                dataAP{indT} = [dataAP{indT}, timestampBl];
                
            end
        end
    end
    
end


totaltime = (simTime)/tstep;
binary_seq = zeros(nT,totaltime);
allBl = ones(1,totaltime); %binary seq of all blocked
Tval = tstep:tstep:totaltime*tstep; %run simulation till tdur with step of tstep
figure; hold on;

for indT = 1:nT
    %     blDur  = exprnd(1/mu);
    for timestamp = 1:length(dataAP{indT})
        blDur  = ceil(exprnd(1/mu)/tstep);
        blTime = ceil(dataAP{indT}(timestamp)/tstep);
        if(blTime+blDur<=simTime/tstep)%avoid excess duration
            binary_seq(indT, blTime:1:(blTime+blDur))=1;
        end
    end
    allBl = allBl & binary_seq(indT,:);
    subplot(nT+1,1,indT)
    plot(binary_seq(indT,:), 'lineWidth',4)
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    set(gca,'ytick',[])
    set(gca,'yticklabel',[])
end
subplot(nT+1,1,nT+1)
plot(Tval,allBl,'r-', 'lineWidth',4)
xlabel('Time (sec)')
% plot(binary_seq(1,:), 'lineWidth',4)


%%Evaluate frequency and average duration of blockage
%frequency = count transitions from 0 to 1
%duration: count total # of 1s
avgFreq = sum(diff(allBl)>0)/simTime;
avgDur = sum(allBl)*tstep/simTime;