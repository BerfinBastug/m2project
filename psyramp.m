function [xr] = ramp(x,rtime,fs);
% [xr] = ramp(x,rtime,fs);
% rtime in seconds!!

lt = length(x);
tr = [0:1/fs:rtime-1/fs];
lr = length(tr);
rampup = ((cos(2*pi*tr/rtime/2+pi)+1)/2).^2; 
rampdown = ((cos(2*pi*tr/rtime/2)+1)/2).^2; 
xr = x;
xr(:,1:lr) = rampup.*x(:,1:lr);
xr(:,lt-lr+1:lt) = rampdown.*x(:,lt-lr+1:lt);
