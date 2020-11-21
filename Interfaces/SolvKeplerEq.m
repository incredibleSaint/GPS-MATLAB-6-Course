function E = SolvKeplerEq(M, e, epsilon)
M = mod(M, 2 * pi);
E = M + e * sin(M);
delta = 1;
while( abs(delta) > epsilon )
   delta = (M - (E - e * sin(E))) / (1 - e * cos(E));
   E = E + delta;
end
%    	En    = M;
% 	delta = (En-e*sin(En)- M)/(1 - e*cos(En));
%     
% 	while ( abs(delta) > epsilon )
% 	    delta = (En - e*sin(En) - M)/(1 - e*cos(En));
%         En = En - delta;
%     end
%  	E = En;
end