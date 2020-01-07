function [x1, y1, x2, y2] = get_points_of_interest(imageset1, imageset2)
    % un 'imageset' est un ensemble de 15 coupes du meme cerveau
    close all;
    figure(1)
    plot_rgb(imageset1, imageset2, false)
    prompt = {'Quelle coupe souhaitez-vous choisir pour placer vos points d interet ?','Combien de points d interet souhaitez-vous placer ?'};
    dlgtitle = 'Input';
    dims = [1 35];
    answer = inputdlg(prompt,dlgtitle,dims)
    coupe = str2num(answer{1});
    nbpoints = str2num(answer{2});
    close all;
    if coupe > 15
        disp('erreur : coupe indiquée n existe pas')
        return
    end


    figure(1)
    imshow(imageset1(:,:,coupe)),hold on
    uiwait(msgbox("Entrez vos points d'intérêt, maintenez contrôle lors du dernier clic.",'Info','modal'))
    [x1, y1] = getpts;
    if size(x1) < nbpoints
        disp('erreur : pas assez de points d interet !')
        return
    end
    x1 = round(x1(1:nbpoints));
    y1 = round(y1(1:nbpoints));
    plot(x1, y1,'.r', 'MarkerSize', 15)

    figure(2)
    imshow(imageset2(:,:,coupe)),hold on
    uiwait(msgbox("Entrez les mêmes points d'intérêt et dans le même ordre, maintenez contrôle lors du dernier clic.",'Info','modal'))
    [x2, y2] = getpts;
    if size(x2) < nbpoints
        disp('erreur : pas assez de points d interet !')
        return
    end
    x2 = round(x2(1:nbpoints));
    y2 = round(y2(1:nbpoints));
    close all;