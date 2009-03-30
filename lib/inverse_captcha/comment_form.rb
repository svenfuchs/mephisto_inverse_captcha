module InverseCaptcha
  class CommentForm < ::Liquid::Block

    def render(context)
      return '' unless Mephisto::Liquid::CommentForm.article.accept_comments?
      result = []
      context.stack do
        if context['message'].blank? 
          errors = context['errors'].blank? ? '' : %Q{<ul id="comment-errors"><li>#{context['errors'].join('</li><li>')}</li></ul>}

          submitted = context['submitted'] || {}
          submitted.each{ |k, v| submitted[k] = CGI::escapeHTML(v) }
        
          sneaky_email_codename = InverseCaptcha::codename(:author_email)
        
          context['form'] = {
            'body'   => %(<textarea id="comment_body" name="comment[body]">#{submitted['body']}</textarea>),
            'name'   => %(<input type="text" id="comment_author" name="comment[author]" value="#{submitted['author']}" />),
            'openid_url'   => %(<input type="text" id="openid_url" name="openid_url" class="open-id" value="#{submitted['openid_url'] || 'http://'}" />),
            'email'  => %(<input type="text" id="comment_author_email" name="comment[author_email]" value="#{submitted['author_email']}" />),
            'sneaky_email'  => %(<input type="text" id="comment_#{sneaky_email_codename}" name="comment[#{sneaky_email_codename}]" value="#{submitted[sneaky_email_codename]}" />),
            'sneaky_email_codename' => sneaky_email_codename,
            'url'    => %(<input type="text" id="comment_author_url" name="comment[author_url]" value="#{submitted['author_url']}" />),
            'submit' => %(<input type="submit" value="Send" />)
          }
        
          result << %(<form id="comment-form" method="post" action="#{context['article'].url}/comments#comment-form">#{[errors]+render_all(@nodelist, context)}</form>)
        else
          result << %(<div id="comment-message">#{context['message']}</div>)
        end
      end
      result
    end
  end    
end
