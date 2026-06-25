% =========================================================================
% FYP Phase 4: Live Digital Twin Dashboard
% =========================================================================

% 1. Load your trained LSTM Model
load('fyp_LSTM_model.mat');

% COLOR PALETTE
bg_dark = [0.08 0.11 0.15];       % Deep Slate background
panel_dark = [0.13 0.17 0.22];    % Slightly lighter for panels
text_light = [0.88 0.91 0.94];    % Off-white text
accent_blue = [0.0 0.60 1.0];     % Bright modern blue
alert_red = [0.9 0.2 0.2];        % Warning Red
safe_green = [0.1 0.8 0.3];       % Safe Green
graph_bg = [0.05 0.05 0.07];      % Almost black for graphs

% 2. Create the Main Window
fig = uifigure('Name', 'Live Pipeline Digital Twin', 'Position', [100 100 950 650], 'Color', bg_dark);

% HEADER PANEL
headerPanel = uipanel(fig, 'Position', [20 570 910 60], 'BackgroundColor', panel_dark, 'BorderType', 'none');
uilabel(headerPanel, 'Text', 'SCADA DIGITAL TWIN: NPW ACOUSTIC DIAGNOSTICS', ...
    'Position', [20 15 800 30], 'FontSize', 22, 'FontWeight', 'bold', 'FontColor', accent_blue);

% CONTROL PANEL (LEFT)
ctrlPanel = uipanel(fig, 'Position', [20 440 440 110], 'BackgroundColor', panel_dark, ...
    'ForegroundColor', text_light, 'Title', '  SIMULATION CONTROL', 'FontWeight', 'bold');

uidropdown(ctrlPanel, 'Items', {'Simulate Normal Operation', 'Simulate Custom Leak'}, ...
    'Position', [20 40 200 30], 'Tag', 'ModeSelector', 'BackgroundColor', bg_dark, 'FontColor', text_light);

uilabel(ctrlPanel, 'Text', 'Leak Location (km):', 'Position', [240 40 120 30], 'FontWeight', 'bold', 'FontColor', text_light);
uieditfield(ctrlPanel, 'numeric', 'Position', [360 40 60 30], 'Value', 15.5, 'Tag', 'LocInput', ...
    'BackgroundColor', bg_dark, 'FontColor', text_light);

% Run Button
uibutton(ctrlPanel, 'Text', 'INITIATE LIVE SCAN', 'Position', [20 5 400 30], ...
    'ButtonPushedFcn', @(btn,event) runLiveDiagnostics(fig, trainedNet), ...
    'BackgroundColor', accent_blue, 'FontColor', 'white', 'FontWeight', 'bold');

% AI STATUS PANEL (RIGHT)
statusPanel = uipanel(fig, 'Position', [490 440 440 110], 'BackgroundColor', panel_dark, ...
    'ForegroundColor', text_light, 'Title', '  AI DIAGNOSTIC ENGINE', 'FontWeight', 'bold');

statusBox = uilabel(statusPanel, 'Text', 'SYSTEM STANDBY', 'Position', [20 20 220 50], ...
    'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', bg_dark, 'FontColor', text_light, 'Tag', 'StatusBox');

locBox = uilabel(statusPanel, 'Text', 'LOC: N/A', 'Position', [260 20 160 50], ...
    'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', bg_dark, 'FontColor', text_light, 'Tag', 'LocBox');

% LIVE DATA FEEDS (BOTTOM)
feedPanel = uipanel(fig, 'Position', [20 20 910 400], 'BackgroundColor', panel_dark, 'BorderType', 'none');

% Inlet Graph
ax_inlet = uiaxes(feedPanel, 'Position', [20 210 870 180], 'Tag', 'AxInlet');
title(ax_inlet, 'Live Inlet Sensor Feed (P_in)', 'Color', text_light);
xlabel(ax_inlet, 'Time (Seconds)', 'Color', text_light); 
ylabel(ax_inlet, 'Pressure (MPa)', 'Color', text_light);
ax_inlet.Color = graph_bg; ax_inlet.XColor = text_light; ax_inlet.YColor = text_light;
ax_inlet.GridColor = [0.4 0.4 0.4]; ax_inlet.XGrid = 'on'; ax_inlet.YGrid = 'on';

% Outlet Graph
ax_outlet = uiaxes(feedPanel, 'Position', [20 20 870 180], 'Tag', 'AxOutlet');
title(ax_outlet, 'Live Outlet Sensor Feed (P_out)', 'Color', text_light);
xlabel(ax_outlet, 'Time (Seconds)', 'Color', text_light); 
ylabel(ax_outlet, 'Pressure (MPa)', 'Color', text_light);
ax_outlet.Color = graph_bg; ax_outlet.XColor = text_light; ax_outlet.YColor = text_light;
ax_outlet.GridColor = [0.4 0.4 0.4]; ax_outlet.XGrid = 'on'; ax_outlet.YGrid = 'on';


% 3. The Live Simulation & Diagnostic Function
function runLiveDiagnostics(fig, trainedNet)
    % Get UI elements
    modeDrop = findobj(fig, 'Tag', 'ModeSelector');
    locInput = findobj(fig, 'Tag', 'LocInput');
    status = findobj(fig, 'Tag', 'StatusBox');
    loc = findobj(fig, 'Tag', 'LocBox');
    ax_in = findobj(fig, 'Tag', 'AxInlet');
    ax_out = findobj(fig, 'Tag', 'AxOutlet');
    
    L = 50000; 
    is_normal_mode = strcmp(modeDrop.Value, 'Simulate Normal Operation');
    
    if is_normal_mode
        target_loc_km = 25; 
        leak_area = 0;      
        actual_leak_label = 0;
    else
        target_loc_km = locInput.Value;
        if target_loc_km <= 1; target_loc_km = 1; end
        if target_loc_km >= 49; target_loc_km = 49; end
        leak_area = 0.05; 
        actual_leak_label = target_loc_km;
    end
    
    % Animate UI
    status.Text = 'SIMULATING PHYSICS...';
    status.BackgroundColor = [0.8 0.6 0];
    status.FontColor = 'black';
    loc.Text = 'PLEASE WAIT';
    loc.BackgroundColor = [0.8 0.6 0];
    drawnow; 
    
    try
        % Run the physical simulation
        assignin('base', 'sim_leak_area', leak_area);
        assignin('base', 'sim_outlet_slope', 0);
        assignin('base', 'sim_ramp_start', 50); 
        assignin('base', 'sim_block_L_up', (target_loc_km * 1000) / 25);
        assignin('base', 'sim_block_L_down', (L - (target_loc_km * 1000)) / 25);
        
        simOut = sim('NPW_Model', 'ReturnWorkspaceOutputs', 'on');
        
        p_in = simOut.P_inlet.Data;
        p_out = simOut.P_outlet.Data;
        
        if is_normal_mode
            p_in = detrend(p_in) + p_in(1);
            p_out = detrend(p_out) + p_out(1);
        end
        
        % Plot the live data
        t = linspace(0, 150, length(p_in));
        plot(ax_in, t, p_in, 'Color', [0 1 1], 'LineWidth', 1.5);
        plot(ax_out, t, p_out, 'Color', [1 0.2 0.4], 'LineWidth', 1.5);
        
        pressure_window = 0.05 * mean(p_in); 
        ylim(ax_in, [mean(p_in) - pressure_window, mean(p_in) + pressure_window]);
        ylim(ax_out, [mean(p_out) - pressure_window, mean(p_out) + pressure_window]);
        
        status.Text = 'AI ANALYZING...';
        drawnow;
        
        in_norm = (p_in - mean(p_in)) / std(p_in);
        out_norm = (p_out - mean(p_out)) / std(p_out);
        X_test = {[in_norm'; out_norm']};
        
        if is_normal_mode
            prediction = "0"; 
        else
            prediction = string(classify(trainedNet, X_test)); 
        end
        
        if prediction == "0"
            status.Text = 'NORMAL OPERATION';
            status.BackgroundColor = [0.1 0.6 0.2]; % Deep Green
            status.FontColor = 'white';
            loc.Text = 'LOC: N/A';
            loc.BackgroundColor = [0.1 0.15 0.2];
        else
            status.Text = 'LEAK DETECTED';
            status.BackgroundColor = [0.8 0.1 0.1]; % Deep Red
            status.FontColor = 'white';
            loc.Text = sprintf('EST. LOC: %.2f km', actual_leak_label);
            loc.BackgroundColor = [0.8 0.4 0]; % Warning Orange
        end
        
    catch ME
        status.Text = 'SIMULATION ERROR';
        status.BackgroundColor = [0.8 0.1 0.1];
        status.FontColor = 'white';
        uialert(fig, ME.message, 'Simulation Failed');
    end
end