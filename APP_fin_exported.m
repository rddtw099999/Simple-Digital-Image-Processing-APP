classdef APP_fin_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure         matlab.ui.Figure
        Menu             matlab.ui.container.Menu
        Menu_2           matlab.ui.container.Menu
        Menu_4           matlab.ui.container.Menu
        GridLayout       matlab.ui.container.GridLayout
        Image            matlab.ui.control.Image
        TabGroup         matlab.ui.container.TabGroup
        Tab              matlab.ui.container.Tab
        Knob             matlab.ui.control.Knob
        Label            matlab.ui.control.Label
        Label_2          matlab.ui.control.Label
        Slider           matlab.ui.control.Slider
        Tab_2            matlab.ui.container.Tab
        RSliderLabel     matlab.ui.control.Label
        RSlider          matlab.ui.control.Slider
        GSliderLabel     matlab.ui.control.Label
        GSlider          matlab.ui.control.Slider
        BSliderLabel     matlab.ui.control.Label
        BSlider          matlab.ui.control.Slider
        Label_4          matlab.ui.control.Label
        Label_5          matlab.ui.control.Label
        expSlider        matlab.ui.control.Slider
        Label_6          matlab.ui.control.Label
        constratSlider   matlab.ui.control.Slider
        Label_7          matlab.ui.control.Label
        saturateSlider   matlab.ui.control.Slider
        SOMSwitchLabel   matlab.ui.control.Label
        SOMSwitch        matlab.ui.control.Switch
        SOMLabel         matlab.ui.control.Label
        SOMSlider        matlab.ui.control.Slider
        resolution_view  matlab.ui.control.Label
        Label_3          matlab.ui.control.Label
        ResetButton      matlab.ui.control.StateButton
    end

    
    properties (Access = public)
       
       img_location;
       file;
       path;
       img_imread
       imgapplied;
       imgresult;
       
       
       rotated=1;
       rotated_temp;
       
   
      
    end
    
    methods (Access = public)
        
        function results = UI_Update(app)
        
            
            apply_all_filter(app); %% ÿÿÿÿÿÿÿfilter
            
            
            org_resolution=size(app.img_imread);%ÿÿÿÿÿÿÿ
            changed_resolution=size(app.imgresult);%ÿÿÿÿÿÿÿÿ
            app.resolution_view.Text=["ÿÿÿÿÿ:("+org_resolution(2)+"x"+org_resolution(1)+") ÿÿÿÿÿÿ:("+changed_resolution(2)+"x"+changed_resolution(1)+")"];
           
        end
    end
    
    
    methods (Access = public)
        %=======================ÿÿÿÿ==========================
        function results = apply_all_filter(app)
        
        
    
        
        if(app.rotated==0)
        
                value = app.Knob.Value;
                      theta=pi*(value/180);
                     T= [cos(theta), -sin(theta), 0;
                        sin(theta), cos(theta), 0;
                          0, 0, 1];
         
                    x_min=0;
                    y_min=0;
                    for i = 1:size(app.imgapplied,1)
                        for j = 1:size(app.imgapplied,2)
                            NewLocation = [i, j, 1]*T;
                            x = round(NewLocation(1));
                            y = round(NewLocation(2));                 
                             if x < x_min
                                     x_min = x;
                             end
                                     if y < y_min
                                      y_min = y;
                                     end
                        end
                    end
                  
                     for i = 1:size(app.imgapplied,1)
                        for j = 1:size(app.imgapplied,2)
                            NewLocation = [i, j ,1]*T;
                            x = round(NewLocation(1));
                            y = round(NewLocation(2));
                            f_changed(x+abs(x_min)+1,y+abs(y_min)+1,:) = app.imgapplied(i,j,:);
                        end
                     end
                   app.rotated=1;
                   app.rotated_temp=f_changed;
        else
            f_changed=app.rotated_temp;
        end
        
        
        
           %=======================ÿÿÿÿ==========================
                    
               factor = app.Slider.Value;            
            T= [ factor, 0, 0;
                 0, factor, 0;
                 0, 0, 1];
            
            h = [0.25 0.5 1 2 1 0.5 0.25]/5.5;
  
            if(factor==1)
                
            else
                f_changed_temp=zeros(1,1,3)
            
            for i = 1:size(f_changed,1)
                for j = 1:size(f_changed,2)
                    NewLocation = [i, j, 1]*T;
                    x = round(NewLocation(1));
                    y = round(NewLocation(2));
                    f_changed_temp(x+1,y+1,:) = f_changed(i,j,:);
                    
                end
            end
            f_changed=f_changed_temp;
            
            if(factor>1)
                for i=1:3
                    for j=1:size(f_changed,1)
                        f_HInterpolation(j,:,i) = conv(f_changed(j,:,i),h); 
                    end
                end
            
                for i=1:3
                    for j=1:size(f_changed,2)
                        f_Interpolated(:,j,i) = conv(f_HInterpolation(:,j,i),h); 
                    end
                end
                f_changed=f_Interpolated*(2*factor);
            end
            end
            

            
            
           %=======================ÿÿRGB========================== 
            f_changed(:,:,1)=f_changed(:,:,1).*(app.RSlider.Value/256);
            f_changed(:,:,2)=f_changed(:,:,2).*(app.GSlider.Value/256);
            f_changed(:,:,3)=f_changed(:,:,3).*(app.BSlider.Value/256);
          
            %=======================ÿÿÿÿÿÿÿ========================== 
            exposure=app.expSlider.Value
            constrat=app.constratSlider.Value
            saturation=app.saturateSlider.Value
            
            f_changed(:,:,1)=((f_changed(:,:,1)-128).*constrat)+128+(128*exposure);
            f_changed(:,:,2)=((f_changed(:,:,2)-128).*constrat)+128+(128*exposure);
            f_changed(:,:,3)=((f_changed(:,:,3)-128).*constrat)+128+(128*exposure);
            
            
            
           
            
            %f(x)=a(x-128)+128+b
            
            
            
            %f_changed =double(imadjust(uint8(f_changed),[0-constrat 0-constrat 0-constrat; 1+constrat 1+constrat 1+constrat],[]));
            
            
            %=======================ÿÿÿÿ==========================

                Pr  =.299
                Pg  =.587
                Pb  =.114
                 P=sqrt((f_changed(:,:,1)).*(f_changed(:,:,1))*Pr+(f_changed(:,:,2)).*(f_changed(:,:,2))*Pg+(f_changed(:,:,3)).*(f_changed(:,:,3))*Pb ) ;

                  f_changed(:,:,1)=P+((f_changed(:,:,1))-P)*saturation;
                  f_changed(:,:,2)=P+((f_changed(:,:,2))-P)*saturation;
                  f_changed(:,:,3)=P+((f_changed(:,:,3))-P)*saturation; 
             
           %===================Do apply SOM===========================
           if (app.SOMSwitch.Value=="On")
               imwrite(uint8(f_changed),"tmp.jpg")
              
               clustered = py.SOM.returnClustered("tmp.jpg", app.SOMSlider.Value);
               %somWeight = py.SOM.returnSomWeight("tmp.jpg", app.SOMSlider.Value);
               %f_changed=double(imread("tmp.jpg"));
               %imshow(uint8(clustered*255))
               
                f_changed=(clustered*255);
                
           end  
       
              app.Image.ImageSource = uint8(f_changed);
              app.imgresult=f_changed;  %ÿÿÿ
              %app.Label_3.Text="";
           
            
           
          

        end
    end
    
    

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: Knob
        function Value_chg(app, event)
                app.rotated=0;
                UI_Update(app);   
            
        end

        % Menu selected function: Menu_2
        function openFile(app, event)
            [app.file,app.path] = uigetfile({'*.*'},...
                          'ÿÿÿÿ');
                      a=[app.path app.file];
             app.img_location=a;
            app.img_imread=imread(app.img_location);
            app.Image.ImageSource = app.img_imread;
            app.imgapplied=double(app.img_imread);
            app.rotated_temp=app.imgapplied;
            UI_Update(app);
        end

        % Value changed function: Slider
        function slider_changed(app, event)

            UI_Update(app);
        end

        % Value changed function: RSlider
        function R_slider(app, event)
            
            UI_Update(app);   
        end

        % Value changed function: GSlider
        function G_slider(app, event)
            
            UI_Update(app);   
        end

        % Value changed function: BSlider
        function B_slider(app, event)
            
            UI_Update(app);   
        end

        % Value changed function: expSlider
        function sxp_changed(app, event)
           
            UI_Update(app);
        end

        % Value changed function: constratSlider
        function constrat_changed(app, event)

            UI_Update(app); 
        end

        % Value changed function: saturateSlider
        function saturate_changed(app, event)
     
            UI_Update(app);
        end

        % Menu selected function: Menu_4
        function saveas(app, event)

             [file,path] = uiputfile({'.jpg';'.bmp'},...
                          'ÿÿÿÿ');
                  
               fullFileName = fullfile(path, file)
               imwrite(uint8(app.imgresult),fullFileName)
        end

        % Value changed function: SOMSwitch
        function En_som(app, event)
            value = app.SOMSwitch.Value
            
            if(value=="On")
                set(app.SOMSlider, 'Enable', "On");
            else
                set(app.SOMSlider, 'Enable', "Off");
            end
            
            UI_Update(app); 
        
        end

        % Value changed function: SOMSlider
        function SOMSLiderChanged(app, event)
 
            UI_Update(app);   
        end

        % Value changed function: ResetButton
        function func_reset(app, event)
            app.Knob.Value=0
            app.Slider.Value=1
            app.RSlider.Value=255
            app.GSlider.Value=255
            app.BSlider.Value=255
            app.expSlider.Value=0
            app.constratSlider.Value=1
            app.saturateSlider.Value=1
            app.SOMSwitch.Value="Off"
            app.SOMSlider.Value=6
            app.rotated=0;
            UI_Update(app); 
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 898 688];
            app.UIFigure.Name = 'UI Figure';

            % Create Menu
            app.Menu = uimenu(app.UIFigure);
            app.Menu.Text = 'ÿÿ';

            % Create Menu_2
            app.Menu_2 = uimenu(app.Menu);
            app.Menu_2.MenuSelectedFcn = createCallbackFcn(app, @openFile, true);
            app.Menu_2.Text = 'ÿÿ';

            % Create Menu_4
            app.Menu_4 = uimenu(app.Menu);
            app.Menu_4.MenuSelectedFcn = createCallbackFcn(app, @saveas, true);
            app.Menu_4.Text = 'ÿÿÿÿ';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '40x', '1x', 150};
            app.GridLayout.RowHeight = {'1x', '25x', '1x'};
            app.GridLayout.RowSpacing = 7.2;
            app.GridLayout.Padding = [10 7.2 10 7.2];

            % Create Image
            app.Image = uiimage(app.GridLayout);
            app.Image.Layout.Row = 2;
            app.Image.Layout.Column = 2;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = 2;
            app.TabGroup.Layout.Column = [3 4];

            % Create Tab
            app.Tab = uitab(app.TabGroup);
            app.Tab.Title = 'ÿÿÿÿ';

            % Create Knob
            app.Knob = uiknob(app.Tab, 'continuous');
            app.Knob.Limits = [0 360];
            app.Knob.MajorTicks = [0 60 120 180 240 300 360];
            app.Knob.ValueChangedFcn = createCallbackFcn(app, @Value_chg, true);
            app.Knob.Position = [42 443 94 94];

            % Create Label
            app.Label = uilabel(app.Tab);
            app.Label.Position = [77 398 42 22];
            app.Label.Text = 'ÿÿ';

            % Create Label_2
            app.Label_2 = uilabel(app.Tab);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.Position = [33 330 29 22];
            app.Label_2.Text = 'ÿÿ';

            % Create Slider
            app.Slider = uislider(app.Tab);
            app.Slider.Limits = [0.1 2];
            app.Slider.MajorTicks = [0.1 0.5 1 1.5 2];
            app.Slider.Orientation = 'vertical';
            app.Slider.ValueChangedFcn = createCallbackFcn(app, @slider_changed, true);
            app.Slider.Position = [95 125 3 196];
            app.Slider.Value = 1;

            % Create Tab_2
            app.Tab_2 = uitab(app.TabGroup);
            app.Tab_2.Title = 'ÿÿ';

            % Create RSliderLabel
            app.RSliderLabel = uilabel(app.Tab_2);
            app.RSliderLabel.HorizontalAlignment = 'right';
            app.RSliderLabel.Position = [10 129 25 22];
            app.RSliderLabel.Text = 'R';

            % Create RSlider
            app.RSlider = uislider(app.Tab_2);
            app.RSlider.Limits = [0 256];
            app.RSlider.ValueChangedFcn = createCallbackFcn(app, @R_slider, true);
            app.RSlider.Position = [56 138 94 3];
            app.RSlider.Value = 256;

            % Create GSliderLabel
            app.GSliderLabel = uilabel(app.Tab_2);
            app.GSliderLabel.HorizontalAlignment = 'right';
            app.GSliderLabel.Position = [-8 74 42 22];
            app.GSliderLabel.Text = 'G';

            % Create GSlider
            app.GSlider = uislider(app.Tab_2);
            app.GSlider.Limits = [0 256];
            app.GSlider.ValueChangedFcn = createCallbackFcn(app, @G_slider, true);
            app.GSlider.Position = [56 84 94 3];
            app.GSlider.Value = 256;

            % Create BSliderLabel
            app.BSliderLabel = uilabel(app.Tab_2);
            app.BSliderLabel.HorizontalAlignment = 'right';
            app.BSliderLabel.Position = [-10 21 42 22];
            app.BSliderLabel.Text = 'B';

            % Create BSlider
            app.BSlider = uislider(app.Tab_2);
            app.BSlider.Limits = [0 256];
            app.BSlider.ValueChangedFcn = createCallbackFcn(app, @B_slider, true);
            app.BSlider.Position = [56 31 94 3];
            app.BSlider.Value = 256;

            % Create Label_4
            app.Label_4 = uilabel(app.Tab_2);
            app.Label_4.Position = [81 164 29 22];
            app.Label_4.Text = 'ÿÿ';

            % Create Label_5
            app.Label_5 = uilabel(app.Tab_2);
            app.Label_5.HorizontalAlignment = 'right';
            app.Label_5.Position = [23 530 29 22];
            app.Label_5.Text = 'ÿÿ';

            % Create expSlider
            app.expSlider = uislider(app.Tab_2);
            app.expSlider.Limits = [-2 2];
            app.expSlider.MajorTicks = [-2 -1 0 1 2];
            app.expSlider.MajorTickLabels = {'-2', '-1', '0', '1', '2'};
            app.expSlider.ValueChangedFcn = createCallbackFcn(app, @sxp_changed, true);
            app.expSlider.MinorTicks = [-2.8 -2.6 -2.4 -2.2 -2 -1.8 -1.6 -1.4 -1.2 -1 -0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8 2 2.2 2.4 2.6 2.8 3];
            app.expSlider.Position = [73 539 77 3];

            % Create Label_6
            app.Label_6 = uilabel(app.Tab_2);
            app.Label_6.HorizontalAlignment = 'right';
            app.Label_6.Position = [23 480 29 22];
            app.Label_6.Text = 'ÿÿ';

            % Create constratSlider
            app.constratSlider = uislider(app.Tab_2);
            app.constratSlider.Limits = [0.1 2];
            app.constratSlider.MajorTicks = [0.1 2];
            app.constratSlider.MajorTickLabels = {'0.1', '2'};
            app.constratSlider.ValueChangedFcn = createCallbackFcn(app, @constrat_changed, true);
            app.constratSlider.MinorTicks = [];
            app.constratSlider.Position = [73 489 77 3];
            app.constratSlider.Value = 1;

            % Create Label_7
            app.Label_7 = uilabel(app.Tab_2);
            app.Label_7.HorizontalAlignment = 'right';
            app.Label_7.Position = [23 419 29 22];
            app.Label_7.Text = 'ÿÿ';

            % Create saturateSlider
            app.saturateSlider = uislider(app.Tab_2);
            app.saturateSlider.Limits = [0.1 2];
            app.saturateSlider.MajorTicks = [0.1 2];
            app.saturateSlider.MajorTickLabels = {'0.1', '2'};
            app.saturateSlider.ValueChangedFcn = createCallbackFcn(app, @saturate_changed, true);
            app.saturateSlider.MinorTicks = [];
            app.saturateSlider.Position = [73 428 77 3];
            app.saturateSlider.Value = 1;

            % Create SOMSwitchLabel
            app.SOMSwitchLabel = uilabel(app.Tab_2);
            app.SOMSwitchLabel.HorizontalAlignment = 'center';
            app.SOMSwitchLabel.Position = [27 335 57 22];
            app.SOMSwitchLabel.Text = 'ÿÿSOM';

            % Create SOMSwitch
            app.SOMSwitch = uiswitch(app.Tab_2, 'slider');
            app.SOMSwitch.ValueChangedFcn = createCallbackFcn(app, @En_som, true);
            app.SOMSwitch.Position = [73 315 45 20];

            % Create SOMLabel
            app.SOMLabel = uilabel(app.Tab_2);
            app.SOMLabel.HorizontalAlignment = 'right';
            app.SOMLabel.Position = [41 271 105 22];
            app.SOMLabel.Text = 'SOMÿÿÿÿÿÿ';

            % Create SOMSlider
            app.SOMSlider = uislider(app.Tab_2);
            app.SOMSlider.Limits = [2 20];
            app.SOMSlider.MajorTicks = [2 5 10 15 20];
            app.SOMSlider.ValueChangedFcn = createCallbackFcn(app, @SOMSLiderChanged, true);
            app.SOMSlider.Enable = 'off';
            app.SOMSlider.Position = [48 259 99 3];
            app.SOMSlider.Value = 6;

            % Create resolution_view
            app.resolution_view = uilabel(app.GridLayout);
            app.resolution_view.Layout.Row = 3;
            app.resolution_view.Layout.Column = 2;
            app.resolution_view.Text = 'ÿÿÿÿÿ:(0x0),ÿÿÿÿÿÿ:(0x0)';

            % Create Label_3
            app.Label_3 = uilabel(app.GridLayout);
            app.Label_3.Layout.Row = 3;
            app.Label_3.Layout.Column = 4;
            app.Label_3.Text = '';

            % Create ResetButton
            app.ResetButton = uibutton(app.GridLayout, 'state');
            app.ResetButton.ValueChangedFcn = createCallbackFcn(app, @func_reset, true);
            app.ResetButton.Text = 'Reset';
            app.ResetButton.Layout.Row = 3;
            app.ResetButton.Layout.Column = 4;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = APP_fin_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end