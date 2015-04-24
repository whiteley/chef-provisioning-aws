require 'spec_helper'

describe "AWS Tagged Items" do
  extend AWSSupport

  when_the_chef_12_server "exists", organization: 'foo', server_scope: :context do
    with_aws "when connected to AWS" do
      it "aws_ebs_volume 'test_volume' created with default Name tag" do
        expect_recipe {
          aws_ebs_volume "test_volume"
        }.to have_aws_ebs_volume_tags('test_volume',
                       { 'Name' => 'test_volume' } )
      end

      it "aws_ebs_volume 'test_volume' tags are updated" do
        expect_recipe {
          aws_ebs_volume "test_volume_a" do
            aws_tags :byebye => 'true'
          end
        }.to have_aws_ebs_volume_tags('test_volume_a',
                                      { 'Name' => 'test_volume_a',
                                        'byebye' => 'true'
                                      })

        expect_recipe {
          aws_ebs_volume "test_volume_a" do
            aws_tags :Name => 'test_volume_b', :project => 'X'
          end
        }.to have_aws_ebs_volume_tags('test_volume_a',
                                      { 'Name' => 'test_volume_b',
                                        'project' => 'X'
                                      })
      end

      it "aws_ebs_volume 'test_volume' created with new Name tag" do
        expect_recipe {
          aws_ebs_volume "test_volume_2" do
            aws_tags :Name => 'test_volume_new'
          end
        }.to have_aws_ebs_volume_tags('test_volume_2',
                                      { 'Name' => 'test_volume_new' } )
      end

      it "aws_ebs_volume 'test_volume' created with custom tag" do
        expect_recipe {
          aws_ebs_volume "test_volume_3" do
            aws_tags :project => 'aws-provisioning'
          end
        }.to have_aws_ebs_volume_tags('test_volume_3',
                                      { 'Name' => 'test_volume_3',
                                        'project' => 'aws-provisioning'
                                      })
      end

      it "aws_instance 'test_instance' created with custom tag", :super_slow do
        expect_recipe {
          machine 'test_instance' do
            action :allocate
          end
        }.to create_an_aws_instance('test_instance')

        expect_recipe {
          aws_instance "test_instance" do
            aws_tags :project => 'FUN'
          end
        }.to have_aws_instance_tags('test_instance',
                                      { 'Name' => 'test_instance',
                                        'project' => 'FUN'
                                      })
      end
    end
  end
end
