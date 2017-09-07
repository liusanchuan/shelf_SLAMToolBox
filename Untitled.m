%figure;

match_range=0.1;  %设置计算匹配度的域值
mu=xrobot;
sigma=[0.4,0,0;
    0,0.4,0;
    0,0,0.1
    ];
sample=mvnrnd(mu,sigma,40);
for i=1:40
    r_temp=sample(i,:);
    drawrobot(r_temp,'g',get(r,'formtype'));
end


[eof,sensors2] = readonestep(files);

sensors(2).steps.data2=[sensors(2).steps.data2;sensors2(2).steps.data2];
sensors(2).steps.data3=[sensors(2).steps.data3;sensors2(2).steps.data3]

score_array=[];
if (length(sensors) >= 2) & ~isempty(sensors(2).steps),
    for i_particle=1:length(sample)
        score=0;
        for i = 1:length(sensors(2).steps.data2),
            xsp = [sensors(2).steps.data2(i); sensors(2).steps.data3(i);0];
            r_temp=sample(i_particle,:);
            xwp(1:3,i) = compound(r_temp,compound(sensors(2).params.xs,xsp));   %先把坐标转换到机器人基础坐标上，然后再转换到全局坐标上面
            
            %% 计算每个扫描点的匹配值：查找域0.2
            laser_point=[xwp(1,i),xwp(2,i)];
            in_range=[];
            for x=1:length(Map_laser(1,:))
                if Map_laser(1,x)<laser_point(1)+match_range && Map_laser(1,x)>laser_point(1)-match_range
                    in_range=[in_range Map_laser(:,x)];
                end
            end
            in_range_y=[];
            if ~isempty(in_range)
                [wu,width]=size(in_range);
                
                for y =1:width
                    if (in_range(2,y)<laser_point(2)+match_range) &&(in_range(2,y)>laser_point(2)-match_range)
                        in_range_y=[in_range_y in_range(:,y)];
                    end
                end
            end
            in_range=in_range_y;
            dis=match_range;
            if ~isempty(in_range)
                for iter=1:length(in_range(1,:))
                    dis_temp=sqrt((laser_point(1)-in_range(1))^2+(laser_point(2)-in_range(2))^2);
                    if dis_temp<dis
                        dis=dis_temp;
                    end
                end
            end
            score=score+(match_range-dis);
        end
        score_array=[score_array score];
        sub_map{i_particle}=xwp;
    end;
    %     subplot(5,8,i_particle);
    %     plot(xwp(1,:),xwp(2,:),'k.','MarkerSize',4);
    %     hold on;
    %     r_temp=sample(i_particle,:);
    %     drawrobot(r_temp,'k',get(r,'formtype'));
    
end
mark=['r.','g.','y.','b.'];
for i=1:4
    best_particle=max(score_array)
    y=find(score_array==best_particle);
    score_array(y)=[];
    xwp=sub_map{y};
    %subplot(2,2,i);
    hold on;
    plot(xwp(1,:),xwp(2,:),'r.','MarkerSize',4);
    hold on;
    r_temp=sample(y,:);
    drawrobot(r_temp,'r',get(r,'formtype'));
end