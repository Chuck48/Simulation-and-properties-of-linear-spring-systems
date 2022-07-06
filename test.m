function main
  
  
% COBWEB

%%{
  nc = 5;
  c = 4;
  
  fixpoints = [nc*c-nc+2:nc*c+1];
  k = 6;  %Federkonstante
  m = 1;  %Masse
  g = 0.01;  #Gravitation
  friction = 1;  %Reibungskoeffizient
  n = nc * c + 1;
  verb = connections(nc,c);
  p_0 = [0,0.1,-5,5];
  C = matrix(nc,c,p_0);
  DistMat = dist_neu(n,C,p_0);
%}



% HÄNGENDE KETTE

%{
  n = 20;
  fixpoints = 1;
  k = 5;  %Federkonstante
  m = 1;  %Masse
  g = 1;  #Gravitation
  friction = 0.4;  %Reibungskoeffizient
  
  verb = {{2}};
  for i = 2:(n-1)
    verb{i}{1} = i-1;
    verb{i}{2} = i+1;
  end
  verb{n}{1} = n-1;
  
  C = [1:n; zeros(1,n); zeros(1,n); zeros(1,n)];
  DistMat = dist_neu(n,C);
%}




% Gitter

%{
  h = 8;
  w = 8;
  n = h*w;
  fixpoints = [(n-w):n];
  k = 5;  %Federkonstante
  m = 1;  %Masse
  g = 0.2;  #Gravitation
  friction = 1;  %Reibungskoeffizient
       
%  C = [repmat(1:w,1,h); floor(((1:n) - 1)/w); zeros(1,n); 0.2 zeros(1,n-1)];
%  C(3,n/2) = 2;
%  C(4,n/2) = -2;
%  DistMat = dist_neu(n,C);
%  verb = gitter(w,h);

%} 
  
  
  gamma = 0.5;
  beta = 0.25;

  X_initial = transpose(transpose(C)(:));
  X = X_initial; % Zeilenmatrix
  tau = 1/16;
  T = 15;
  timesteps = floor(T/tau);
  
  
  positions_stored = zeros(2*n,timesteps);

  for t = 1:timesteps
    t

    %Verlet Method
    
    %%{
    f_temp = f(X,n,fixpoints,verb,tau,k,m,friction,g,DistMat);
    temp_velocity = X(2*n+1:4*n) + tau/2 * f_temp;
    
    X(1:2*n) = X(1:2*n) + tau * temp_velocity;
    X(2*n+1:4*n) = X(2*n+1:4*n) + tau/2 * f(X,n,fixpoints,verb,tau,k,m,friction,g,DistMat) +  tau/2 * f_temp;
    
    %}
        
    %x_new,v_new berechnen mittels X
    
    
    %initale Werte für Fixpunktiteration
    
    %{
    
    x_old = X(1,1:(2*n));
    v_old = X(1,(2*n+1):(4*n));
    a_old = 1/m * f(X,n,fixpoints,verb,tau,k,m,friction,g,DistMat);
    
    x_new = x_old;
    v_new = v_old;
    a_new = a_old;
    
    
    
    %Fixpunktiteration
    iter = 0;
    
    do
      v_new_temp = v_old + (1-gamma)*tau*a_old + gamma*tau*a_new;
      x_new_temp = x_old + tau* v_new + tau**2/2*((1-2*beta)*a_old + 2*beta*a_new);
      a_new_temp = 1/m * f([x_new,v_new],n,fixpoints,verb,tau,k,m,friction,g,DistMat); %X durch X_new ersetzten
    
      error = norm(x_new - x_new_temp);
      
      v_new = v_new_temp;
      x_new = x_new_temp;
      a_new = a_new_temp;
      
      
      iter += 1;
    until(iter > 50 || error < 10**(-3))
    

    
    %X aus x_new,v_new berechnen
    X = [x_new,v_new];
    
    %}
    
    
    positions_stored(:,t) = X(1:2*n);
  end

  clf;
  %figHandle = figure(1);
  
  
  axis([-10,10,-10,10]);
  %axis([-3,2*w+1,-h,2*h+1]);
  %axis([-2*n,2*n,-5*n,n]);
  for t = 1:timesteps
    if rem(t,4) == 0
      t
      clf;
      x = positions_stored(1:n,t); % die x Werte der n Punkte
      y = positions_stored(n+1:2*n,t);  % die y Werte der n Punkte

        % Zeichnet die Punkte.
      axis([-10,10,-10,10]);
      %axis([-3,2*w+1,-h,2*h+1]);
      %axis([-2*n,2*n,-5*n,n]);
      for i = 1:n
        for j = cell2mat(verb{i})
          line([x(i),x(j)],[y(i),y(j)]);
        end
      end
      drawnow;
      %MakeGif(figHandle, 'test.gif');
    end    
  end
end

main() %führe alles aus
