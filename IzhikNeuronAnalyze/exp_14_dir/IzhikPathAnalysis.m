%% StreamLine Plot

a = InputStateSparse.a(1);
b = InputStateSparse.b(1);

[U, V] = meshgrid(-20:0.5:15, -100:8:30);

onemsbyTstep = 10;

figure;
hold on;
for i = 1:size(U, 2)
    for j = 1:size(U, 1)
        [LineU, LineV] = getIzhikLineofConv(a,b,[U(j,i), V(j,i)], onemsbyTstep);
        plot(LineU, LineV);
    end
    if (mod(U(1,i), 5) == 0)
        fprintf('Completed U = %f\n', U(1,i));
    end
end

% LargeVects = dV.^2 + dU.^2 > 25;
% LargeVectMags = sqrt(dV(LargeVects).^2 + dU(LargeVects).^2);
% 
% dU(LargeVects) = dU(LargeVects)*5./LargeVectMags;
% dV(LargeVects) = dV(LargeVects)*5./LargeVectMags;
% clear LargeVects;
% 
% figure;
% quiver(U, V, dU, dV);

%% Testing some trajectories and approximation
a = InputStateSparse.a(1);
b = InputStateSparse.b(1);

InitPoint1 = [40, -50];
InitPoint2 = [20, -50];
InitPoint3 = [-13, -100];
InitPoint3 = [-20, -100];

onemsbyTstep = 20;

[U1, V1] = getIzhikTrajectory(a,b,InitPoint1,onemsbyTstep);
[U2, V2] = getIzhikTrajectory(a,b,InitPoint2,onemsbyTstep);
[U3, V3] = getIzhikTrajectory(a,b,InitPoint3,onemsbyTstep);
U4 = U1;
% Eqn = 0.04V^2 + 5V + 140 - U = 0
% => V = (-5 - sqrt(25 - 4*0.04*(140-U)))*12.5
V4 = (-5 - sqrt(25-4*0.04*(140-U4)))*12.5;

figure;
plot(U1, V1);
hold on;
plot(U2, V2);
plot(U3, V3);
plot(U4, V4);
hold off;
