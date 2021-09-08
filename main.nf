#!/usr/bin/env nextflow

params.outdir = '.'


Channel
  .fromPath('/home/ubuntu/htan-dcc-image-prep/test_data/*.ome.tif')
  .into { ome_story_ch; ome_view; ome_pyramid_ch }

ome_view.view()
//not_ome_ch = Channel.fromPath('~/miniature/data/*{.svs,.tif,.tiff}')


//process make_ometiff{
//  input:
//    path not_ome from not_ome_ch
//
//  output:
//    path 'converted.ome.tiff' into ome_ch
//
//  script:
//  """
//  bioformats2raw {$not_ome} 'raw_dir'
//  raw2bioformats 'raw_dir' 'converted.ome.tiff'
//
//  """
//}

process make_story{
  conda '/home/ubuntu/anaconda3/envs/auto-minerva-author'
  echo true
  input:
    path ome from ome_story_ch
  output:
    path('story.json') into story_ch
  """
  python $projectDir/auto-minerva/story.py $ome > 'story.json'
  """
}

process render_pyramid{
  publishDir "$params.outdir"
  echo true
  conda '/home/ubuntu/anaconda3/envs/auto-minerva-author'
  input:
    path ome from ome_pyramid_ch
    path story from story_ch
  output:
    path('*_minerva') into ch_final

    """
    python  $projectDir/minerva-author/src/save_exhibit_pyramid.py" $ome $story
    """
}
