function [Data_TV,avg_votenum] = Reversed_Sparse_Ball_fast(data, Sigma, Sigma_noise, method, index_mat_vote, S)


if strcmp( method, 'Std2' ) == 1 % Sparse Standard Ball Tensor Voting with my code
    
    disp('Std2');
    disp('faster version');
    D = size( data, 2 );
    N = size( data, 1 );
    votenum = 0;
    %S = pdist2(data(:, 1:D), data(:, 1:D));
    data_inv=(data(:, 1:D))';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    S =L2_distance(data_inv,data_inv);
    S=S';
    F = S<2*sqrt(Sigma);
    size(F)
       for i = 1 : size( data, 1 )
       Data_TV(i,1:D) = data(i,1:D);
       Data_TV(i,D+1) = 1;
       Tensor = zeros(D,D); % 2nd order tensor - matrix
       temp_nei_i=index_mat_vote(:,i);
       length(temp_nei_i);
       l=length(temp_nei_i);
        for j = 1:l
        idxNeig = temp_nei_i(j);
        dis = S(idxNeig,i);
           % if (dis > 0) & (F(i,idxNeig))
         if (dis > 0) & (F(idxNeig,i))
                votenum = votenum + 1;
               % dir = ( data(i,1:D) - data(idxNeig,1:D) ) / dis;
                % dir = ( data(i,1:D) - data(index_mat_vote(idxNeig,i),1:D) ) / dis;
                dir = ( data(i,1:D) - data(idxNeig,1:D) ) ;
                Tensor = Tensor + exp( -dis^2/ Sigma ) * (eye(D) - dir'*dir);
             %   Stick= exp( -dis^2/ Sigma ) * (eye(D) - dir'*dir);%%
              %  Stick_column=Stick(:);%%
                %Reversed_Votes{i}(:,idxNeig)=Stick_column;%%
            end
        end
        error_vec=zeros(1,N);
       [U1,S1,V1] = rsvd(Tensor,2);
 %Extract first k eigenvlaues and k eigenvectors: 

 %disp('fast SVD computing');
 temp_dim=2;
 if  isempty(S1)==1
     S1 = zeros(temp_dim,D);
     U1 = zeros(D,temp_dim);
     V1 = zeros(D,temp_dim);
 end
      Lam_k=S1(1:temp_dim,:);
      Vec_k=U1*V1';
      % [L,J] = sort( diag(Lam) );
        [L,J] = sort( diag(Lam_k) );
        for k = 1 : temp_dim
        %Data_TV(i,D+1+k) =  Lam(J(D-k+1),J(D-k+1));% here the ranking is very important, a slight error before but revised now^_^
        Data_TV(i,D+1+k) =  Lam_k(J(temp_dim-k+1),J(temp_dim-k+1));
        end
        Data_TV(i, D+1+temp_dim+1 : (2*D)+1 )= 0;
        for k = 1 : temp_dim % instead of D
        %Data_TV( i, 2*D+1+(k-1)*D+1 : 2*D+1+k*D ) = Vec(:,J(D-k+1));
        Data_TV( i, 2*D+1+(k-1)*D+1 : 2*D+1+k*D ) = Vec_k(:,J(temp_dim-k+1));
        end
      
    end
    avg_votenum=votenum/N;
    disp('Average Vote is'); disp(votenum/N);   
      
end



