clc
clear all;
close all;

measurement_length = 3;

d=dir('edge_03*.csv');
d_con = dir('edge_con_03*.csv');
files = cell(length(d), 1);
files_con = cell(length(d_con), 1);

WARN = false;

for i = 1: length(d)
    files{i} = xlsread(d(i).name);
    files_con{i} = xlsread(d_con(i).name);
end 


lens = zeros(1, length(d));
lens_con = zeros(1, length(d_con));

for i = 1: length(d)
    lens(i) = length(files{i}(:, 2));
    lens_con(i) = length(files_con{i}(:, 2));
end

trun = min(lens) - 1;
trun_con = min(lens_con) - 1;

if trun > trun_con
    truncate = trun_con;
else
    truncate = trun;
end

offset = zeros(length(lens), 1);
offset_con = zeros(length(lens), 1);

for i = 1: length(lens)
    offset(i) = abs(lens(i) - truncate);
    offset_con(i) = abs(lens_con(i) - truncate);
end

if max(offset) > 300
    ERR = true;
    e = msgbox('Error: Data Sizes Incorrect', 'Error - Data Sizes', 'error');
    uiwait(e);
    return
end


dis = zeros(length(d), truncate);
dis_con = zeros(length(d_con), truncate);

wear = zeros(length(d), truncate);

init_diff = zeros(length(d), 1);

for i = 1: length(d)
    
    temp = files{i}(:, 2);
    temp = temp(offset(i):end-1);
    dis(i, :) = temp / 1000;
    
    temp = files_con{i}(:, 2);
    temp = temp(offset_con(i):end-1);
    dis_con(i, :) = temp / 1000;
    
    init_diff(i) = abs(dis(i, 1) -  dis_con(i, 1));
    
    if init_diff(i) > 200
        e = msgbox('ERR: Offset Too Large', 'Error - Offset', 'error');
        ERR = true;
        uiwait(e);
        return
    end 
end

for i = 1: length(d)
    for j = 1: truncate
        wear(i, j) = abs(dis(i, j) - dis_con(i, j));
    end
end

AvWear = mean(wear);
Av = mean(AvWear);

if Av > 200
    WARN = true;
    warning = "Warning: Potential Data Fault";
end

if WARN == true
    w = msgbox(warning, 'Warning', 'warn');
    uiwait(w);
end
% 
% x_axis_measurement_con = 0:measurement_length /(truncate - 1): measurement_length;
% 
% for i=1: length(d)
%     figure;
%     hold on; grid on; box on;
%     g06 = plot(x_axis_measurement_con, dis(i, :));
%     c06 = plot(x_axis_measurement_con, dis_con(i, :), 'r-');
%     title('Turning Tool Surface Displacement Measurement');
%     xlabel('Confocal Displacement Sensor Samples (mm)');
%     ylabel('Surface Displacement (\mum)');
%     legend('Initial Experimental Measurement', 'Control Measurement', 'Location', 'NorthWest');
%     
%     figure;
%     hold on; axis on; box on; grid on;
%     plot(x_axis_measurement_con, wear (i, :));
%     title('Tool Wear Measurement');
%     xlabel('Position From Reference x_axis_measurement (mm)');
%     ylabel('Tool Wear (\mum)');
% end

Vmax = max(abs(wear));
Vmean = mean(abs(wear));

Vb_max = max(Vmean);
Vb = mean(Vmean);

if Vb > 100
    WARN = true;
    warning = "Warning: Potential Data Fault";
end

if WARN == true
    w = msgbox(warning, 'Warning', 'warn');
    uiwait(w);
end


figure;
imagesc(wear);
colorbar;

fprintf('Vb: '); 
disp(Vb);
fprintf('Vb_max: '); 
disp(Vb_max);