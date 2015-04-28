# chef-provisioning-aws

An implementation of the AWS driver using the AWS Ruby SDK (v1).  It also implements a large number of AWS-specific resources such as:

* SQS Queues
* SNS Topics
* Elastic Load Balancers
* VPCs
* Security Groups
* Instances
* Images
* Autoscaling Groups
* SSH Key pairs
* Launch configs

# Running Integration Tests

To run the integration tests execute `bundle exec rake integration`.  If you have not set it up,
you should see an error message about a missing environment variable `AWS_TEST_DRIVER`.  You can add
this as a normal environment variable or set it for a single run with `AWS_TEST_DRIVER=aws::eu-west-1
bundle exec rake integration`.  The format should match what `with_driver` expects.

You will also need to have configured your `~/.aws/config` or environment variables with your
AWS credentials.

This creates real objects within AWS.  The tests make their best effort to delete these objects
after each test finishes but errors can happen which prevent this.  Be aware that this may charge
you!

If you find the tests leaving behind resources during normal conditions (IE, not when there is an
unexpected exception) please file a bug.  Most objects can be cleaned up by deleting the `test_vpc`
from within the AWS browser console.

# Tagging Resources

## Aws Resources

All resources which extend Chef::Provisioning::AWSDriver::AWSResourceWithEntry support the ability
to add tags, except AwsEipAddress.  AWS does not support tagging on AwsEipAddress.  To add a tag
to any aws resource, us the `aws_tags` attribute and provide it a hash:

```ruby
aws_ebs_volume 'ref-volume' do
  aws_tags company: 'my_company', 'key_as_string' => :value_as_symbol
end

aws_vpc 'ref-vpc' do
  aws_tags 'Name' => 'custom-vpc-name'
end
```

The hash of tags can use symbols or strings for both keys and values.  The tags will be converged
idempotently, meaning no write will occur if no tags are changing.

We will not touch the `'Name'` tag UNLESS you specifically pass it.  If you do not pass it, we
leave it alone.

Because base resources from chef-provisioning do not have the `aws_tag` attribute, they must be
tagged in their options:

```ruby
machine 'ref-machine-1' do
  machine_options aws_tags: {:marco => 'polo', :happyhappy => 'joyjoy'}
end

machine_batch "ref-batch" do
  machine 'ref-machine-2' do
    machine_options aws_tags: {:marco => 'polo', :happyhappy => 'joyjoy'}
    converge false
  end
  machine 'ref-machine-3' do
    machine_options aws_tags: {:othercustomtags => 'byebye'}
    converge false
  end
end

load_balancer 'ref-elb' do
  load_balancer_options aws_tags: {:marco => 'polo', :happyhappy => 'joyjoy'}
end

machine_image "ref-image" do
  image_options aws_tags: {:marco => 'polo', :happyhappy => 'joyjoy'}
end
```

See `docs/examples/aws_tags.rb` for further examples.
