describe FlickrUpdateJob::CommentUpdater do
  let(:photo) { create :flickr_update_photo }

  it "loads comments from Flickr" do
    stub_request_to_return_one_comment
    described_class.update photo
    photo_has_the_comment_from_the_request
  end

  it "deletes previous comments" do
    create :comment, photo: photo
    stub_request_to_return_one_comment
    described_class.update photo
    photo_has_the_comment_from_the_request
  end

  it "does not delete previous comments if the photo currently has no comments" do
    create :comment, photo: photo
    allow(FlickrService.instance).to receive(:photos_comments_get_list).and_return({
      'comments' => [{}]
    })
    described_class.update photo
    expect(photo.comments.length).to eq(1)
    expect(Comment.count).to eq(1)
  end

  it "leaves previous comments alone if the request for comments fails" do
    create :comment, photo: photo
    allow(FlickrService.instance).to receive(:photos_comments_get_list).and_raise(FlickrService::FlickrRequestFailedError)
    described_class.update photo
    expect(Comment.count).to eq(1)
  end

  it "ignores a comment with no content" do
    allow(FlickrService.instance).to receive(:photos_comments_get_list).with(photo_id: photo.flickrid).and_return({
      'comments' => [
        {
          'comment' => [
            {
              'author' => 'commenter_flickrid',
              'authorname' => 'commenter_username',
              'content' => 'comment text',
              'datecreate' => '1356998400'
            },
            {
              'author' => 'commenter_flickrid_2',
              'authorname' => 'commenter_username_2',
              'datecreate' => '1356998401'
            }
          ]
        }
      ]
    })
    described_class.update photo
    photo_has_the_comment_from_the_request
  end

  it "does not delete previous comments if the photo only has a comment with no content" do
    create :comment, photo: photo
    allow(FlickrService.instance).to receive(:photos_comments_get_list).with(photo_id: photo.flickrid).and_return({
      'comments' => [
        {
          'comment' => [
            {
              'author' => 'commenter_flickrid_2',
              'authorname' => 'commenter_username_2',
              'datecreate' => '1356998401'
            }
          ]
        }
      ]
    })
    described_class.update photo
    expect(photo.comments.length).to eq(1)
    expect(Comment.count).to eq(1)
  end

  def stub_request_to_return_one_comment
    allow(FlickrService.instance).to receive(:photos_comments_get_list).with(photo_id: photo.flickrid).and_return({
      'comments' => [{
        'comment' => [{
          'author' => 'commenter_flickrid',
          'authorname' => 'commenter_username',
          'content' => 'comment text',
          'datecreate' => '1356998400'
        }]
      }]
    })
  end

  def photo_has_the_comment_from_the_request
    expect(photo.comments.length).to eq(1)
    expect(photo.comments.first).to have_attributes?(
      flickrid: 'commenter_flickrid',
      username: 'commenter_username',
      comment_text: 'comment text',
      commented_at: Time.utc(2013)
    )
  end
end
