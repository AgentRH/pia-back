class UserMailer < ApplicationMailer
  # Invitation : création d'un compte par un administrateur
  def uuid_created
    prepare_context
    @user = params[:user]
    @action_url = front_link("activation=#{@user.uuid}")

    mail(to: @user.email, subject: "Invitation à l'espace conformité AgentRH#{subject_suffix}")
  end

  # Nouveau code : soit le compte n'est pas encore activé (adresse corrigée par
  # un administrateur), soit l'utilisateur a demandé à réinitialiser son mot de passe.
  def uuid_updated
    prepare_context
    @user = params[:user]
    @pending_activation = @user.access_locked?

    if @pending_activation
      @action_url = front_link("activation=#{@user.uuid}")
      subject = "Votre code d'activation pour l'espace conformité AgentRH#{subject_suffix}"
    else
      @action_url = front_link("reset=#{@user.uuid}")
      subject = "Réinitialisation de votre mot de passe · espace conformité AgentRH"
    end

    mail(to: @user.email, subject: subject)
  end

  def section_ready_for_evaluation
    prepare_context
    @pia_name = params[:pia] ? params[:pia].name : ''
    @evaluator = params[:evaluator]
    @action_url = front_link

    mail(to: @evaluator.email, subject: "Une partie de l'analyse « #{@pia_name} » attend votre évaluation")
  end

  def section_ready_for_validation
    prepare_context
    @pia_name = params[:pia] ? params[:pia].name : ''
    @validator = params[:validator]
    @action_url = front_link

    mail(to: @validator.email, subject: "Une partie de l'analyse « #{@pia_name} » attend votre validation")
  end
end
