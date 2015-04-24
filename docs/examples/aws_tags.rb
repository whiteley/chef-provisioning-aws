require 'chef/provisioning/aws_driver'

with_driver 'aws::us-west-2'

machine 'ref-machine-1' do
  action :allocate
end

aws_instance 'ref-machine-1' do
  aws_tags :marco => 'polo', :happyhappy => 'joyjoy'
end

aws_instance 'ref-machine-1' do
  aws_tags :othercustomtags => 'byebye'
end

aws_instance 'ref-machine-1' do
  aws_tags :Name => 'new-name'
end

machine 'ref-machine-1' do
  action :destroy
end
