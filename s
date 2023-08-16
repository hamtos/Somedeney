
[1mFrom:[0m /home/ec2-user/environment/Somedeney/app/controllers/public/notes_controller.rb:14 Public::NotesController#create:

     [1;34m9[0m: [32mdef[0m [1;34mcreate[0m
    [1;34m10[0m:   [1;34m# noteモデル[0m
    [1;34m11[0m:   @note = [1;34;4mNote[0m.new(note_params)
    [1;34m12[0m:   @note.tags = [1;34;4mTag[0m.where([35mid[0m: params[[33m:note[0m][[33m:tag_id[0m])
    [1;34m13[0m:   binding.pry
 => [1;34m14[0m:   [32mif[0m @note.save
    [1;34m15[0m:     redirect_to root_path
    [1;34m16[0m:   [32melse[0m
    [1;34m17[0m:     @note = [1;34;4mNote[0m.new
    [1;34m18[0m:     @lat = [1;35m35.625166[0m
    [1;34m19[0m:     @lng = [1;35m139.243611[0m
    [1;34m20[0m:     @tag_list = [1;34;4mTag[0m.pluck([33m:name[0m, [33m:id[0m)
    [1;34m21[0m:     render [31m[1;31m"[0m[31mnew[1;31m"[0m[31m[0m
    [1;34m22[0m:   [32mend[0m
    [1;34m23[0m: [32mend[0m

