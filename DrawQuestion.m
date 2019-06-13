function [reaction_time,q_resp] = DrawQuestion(question, question_pos, poles,poles_pos,...
                                            ycenter, right_LineEdge,left_LineEdge, line_vert,...
                                            top_all,bottom_all, markercolor,markercenter, size_marker,...
                                            windowptr, RateOnset,mvfac,left_High)
    mouseclick = [0,0,0];
    keyIsDown = 0;
    response_duration = 3;
    q_resp = nan;
    while ~keyIsDown && GetSecs - RateOnset < response_duration,  %or a certain amount of time has passed, say 4 seconds. if 4secs have passed, then NaN response
        [x,y,mouseclick] = GetMouse();%checks position of mouse

        if mouseclick(1),%%%%%if response is made don't do anything
        else %speed mouse
            px = x;
             mvx = mvfac*(x-px) + x;
            SetMouse(mvx,y,windowptr);
        end
%Set up marker boundary positions- prevent going over
%boundary
        markerleft = x-markercenter;%set locations of marker sides in relation to cursor
        markerright = x + markercenter;
        if markerleft > right_LineEdge,%if cursor moves past line, marker remains at end of line
            markerleft = right_LineEdge;
            markerright = right_LineEdge + size_marker;
        elseif markerright < left_LineEdge,
            markerright = left_LineEdge;
            markerleft = left_LineEdge - size_marker;
        end%if

%Draw the screen
        Screen('Drawtext',windowptr,question,question_pos,ycenter);%Displays text
        Screen('Drawtext',windowptr,poles{1},poles_pos,top_all);
        Screen('Drawtext',windowptr,poles{2},left_High,top_all);
        Screen('DrawLine',windowptr,[],right_LineEdge,line_vert,left_LineEdge,line_vert);
%Position the marker
        Screen('FillRect',windowptr,markercolor,[markerleft,top_all,markerright,bottom_all]);%marker set at x position of mouse
        Screen('Flip', windowptr); %Flips to rating screen

        if mouseclick(1),%if response is made
            keyIsDown = 1;%break out of loop
            reaction_time = GetSecs - RateOnset;%get response time for post stimulus qs
            resp = x; %get position of cursor
            if resp < left_LineEdge,
                resp = left_LineEdge;
            elseif resp > right_LineEdge,
                resp = right_LineEdge;
            end
                q_resp = (resp-left_LineEdge)/(right_LineEdge-left_LineEdge); %converted to percentage
                
                WaitSecs(.1); %prevent keyboard spillover
        end
    end
    
    if(~isnan(q_resp))
    %Re-Draw the screen without marker
        Screen('Drawtext',windowptr, question, question_pos,ycenter);%Displays text
        Screen('Drawtext',windowptr,poles{1},poles_pos,top_all);
        Screen('Drawtext',windowptr,poles{2},left_High,top_all);
        Screen('DrawLine',windowptr,[],right_LineEdge,line_vert,left_LineEdge,line_vert);
        Screen('Flip', windowptr); %Flips to rating screen

        remaining_time = response_duration - (GetSecs - RateOnset);
        WaitSecs(remaining_time);
    else
        reaction_time= nan;
        q_resp = nan;
    end
        
end

